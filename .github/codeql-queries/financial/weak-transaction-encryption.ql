/**
 * @name Weak transaction encryption
 * @description Detects use of weak or deprecated encryption algorithms for financial transactions
 * @kind problem
 * @problem.severity error
 * @security-severity 8.5
 * @precision high
 * @id java/weak-transaction-encryption
 * @tags security
 *       external/rbi
 *       external/sebi
 *       encryption
 *       financial-transactions
 */

import java

/**
 * Weak or deprecated encryption algorithms that should not be used for financial data
 */
class WeakEncryptionAlgorithm extends string {
  WeakEncryptionAlgorithm() {
    this = [
      // Weak symmetric algorithms
      "DES", "DESede", "3DES", "TripleDES", "RC2", "RC4", "RC5",
      // Weak modes
      "ECB", "CBC", 
      // Weak hash algorithms
      "MD5", "SHA1", "SHA-1",
      // Weak key exchange
      "DH", "DHE", "ECDH",
      // Deprecated TLS versions
      "TLSv1", "TLSv1.1", "SSLv2", "SSLv3"
    ]
  }
}

/**
 * Financial transaction related classes or methods
 */
predicate isFinancialTransactionContext(Callable c) {
  c.getName().toLowerCase().matches([
    "%payment%", "%transaction%", "%transfer%", "%deposit%",
    "%withdrawal%", "%credit%", "%debit%", "%settlement%",
    "%clearing%", "%reconcil%"
  ])
  or
  c.getDeclaringType().getName().toLowerCase().matches([
    "%payment%", "%transaction%", "%transfer%", "%settlement%",
    "%bank%", "%financial%", "%money%", "%fund%"
  ])
}

/**
 * Cipher initialization with weak algorithms
 */
class WeakCipherInit extends MethodAccess {
  WeakCipherInit() {
    this.getMethod().hasName("getInstance") and
    this.getMethod().getDeclaringType().hasQualifiedName("javax.crypto", "Cipher") and
    exists(string algorithm |
      this.getArgument(0).(StringLiteral).getValue().toUpperCase().matches("%" + algorithm.toUpperCase() + "%") and
      algorithm instanceof WeakEncryptionAlgorithm
    )
  }
  
  string getWeakAlgorithm() {
    exists(WeakEncryptionAlgorithm weak |
      this.getArgument(0).(StringLiteral).getValue().toUpperCase().matches("%" + weak.toUpperCase() + "%") and
      result = weak
    )
  }
}

/**
 * SSL/TLS context with weak protocols
 */
class WeakSSLContext extends MethodAccess {
  WeakSSLContext() {
    this.getMethod().hasName("getInstance") and
    this.getMethod().getDeclaringType().hasQualifiedName("javax.net.ssl", "SSLContext") and
    exists(WeakEncryptionAlgorithm weak |
      this.getArgument(0).(StringLiteral).getValue() = weak and
      result = weak
    )
  }
  
  string getWeakProtocol() {
    exists(WeakEncryptionAlgorithm weak |
      this.getArgument(0).(StringLiteral).getValue() = weak and
      result = weak
    )
  }
}

/**
 * Message Digest with weak algorithms
 */
class WeakMessageDigest extends MethodAccess {
  WeakMessageDigest() {
    this.getMethod().hasName("getInstance") and
    this.getMethod().getDeclaringType().hasQualifiedName("java.security", "MessageDigest") and
    exists(WeakEncryptionAlgorithm weak |
      this.getArgument(0).(StringLiteral).getValue().toUpperCase() = weak.toUpperCase() and
      result = weak
    )
  }
  
  string getWeakDigest() {
    exists(WeakEncryptionAlgorithm weak |
      this.getArgument(0).(StringLiteral).getValue().toUpperCase() = weak.toUpperCase() and
      result = weak
    )
  }
}

from Expr weakness, string algorithm, string context
where 
  (
    weakness instanceof WeakCipherInit and
    algorithm = weakness.(WeakCipherInit).getWeakAlgorithm() and
    context = "cipher"
  ) or
  (
    weakness instanceof WeakSSLContext and
    algorithm = weakness.(WeakSSLContext).getWeakProtocol() and
    context = "SSL/TLS"
  ) or
  (
    weakness instanceof WeakMessageDigest and
    algorithm = weakness.(WeakMessageDigest).getWeakDigest() and
    context = "message digest"
  )
  and
  // Only flag if used in financial transaction context
  isFinancialTransactionContext(weakness.getEnclosingCallable())
select weakness,
  "Weak " + context + " algorithm '" + algorithm + "' used in financial transaction context. " +
  "RBI guidelines require strong encryption (AES-256, RSA-2048+, SHA-256+) for financial data."