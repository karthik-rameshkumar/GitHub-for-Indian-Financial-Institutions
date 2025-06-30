/**
 * @name Payment data exposure through logging
 * @description Detects when payment-related data might be exposed through logging statements
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id java/payment-data-exposure-logging
 * @tags security
 *       external/rbi
 *       external/pci-dss
 *       payment-processing
 */

import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * Payment-related data that should never be logged
 */
class PaymentSensitiveData extends Expr {
  PaymentSensitiveData() {
    // Credit card numbers
    this.(FieldAccess).getField().getName().toLowerCase().matches([
      "%card%number%", "%cardnumber%", "%ccnumber%", "%creditcard%",
      "%debit%card%", "%pan%", "%primary%account%number%"
    ])
    or
    // CVV/CVC codes
    this.(FieldAccess).getField().getName().toLowerCase().matches([
      "%cvv%", "%cvc%", "%security%code%", "%card%verification%"
    ])
    or
    // Bank account details
    this.(FieldAccess).getField().getName().toLowerCase().matches([
      "%account%number%", "%routing%number%", "%ifsc%", "%swift%",
      "%bank%account%", "%account%details%"
    ])
    or
    // Payment tokens and secrets
    this.(FieldAccess).getField().getName().toLowerCase().matches([
      "%payment%token%", "%auth%token%", "%payment%secret%",
      "%transaction%key%", "%merchant%key%"
    ])
    or
    // UPI and digital payment identifiers
    this.(FieldAccess).getField().getName().toLowerCase().matches([
      "%upi%id%", "%vpa%", "%payment%handle%", "%wallet%id%"
    ])
  }
}

/**
 * Logging methods that could expose sensitive data
 */
class LoggingMethod extends Method {
  LoggingMethod() {
    this.getDeclaringType().hasQualifiedName([
      "org.slf4j", "org.apache.logging.log4j", "java.util.logging",
      "ch.qos.logback", "org.apache.commons.logging"
    ], _) and
    this.getName().matches(["debug", "info", "warn", "error", "trace", "log"])
    or
    // System.out.print methods
    this.getDeclaringType().hasQualifiedName("java.lang", "System") and
    this.getName().matches(["print", "println"])
    or
    // Custom logging frameworks
    this.getName().toLowerCase().matches(["%log%", "%print%", "%write%"])
  }
}

/**
 * Taint tracking from payment data to logging calls
 */
class PaymentDataToLoggingConfig extends TaintTracking::Configuration {
  PaymentDataToLoggingConfig() { this = "PaymentDataToLoggingConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof PaymentSensitiveData
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma |
      ma.getMethod() instanceof LoggingMethod and
      sink.asExpr() = ma.getAnArgument()
    )
  }

  override predicate isSanitizer(DataFlow::Node node) {
    // Data is sanitized if it's masked or encrypted
    exists(MethodAccess ma |
      ma.getMethod().getName().toLowerCase().matches([
        "%mask%", "%encrypt%", "%hash%", "%redact%", "%anonymize%"
      ]) and
      node.asExpr() = ma
    )
  }
}

from PaymentDataToLoggingConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "Payment-sensitive data from $@ may be exposed through logging, violating PCI DSS and RBI guidelines.",
  source.getNode(), "this payment data field"