/**
 * @name PII exposure in financial applications
 * @description Detects potential exposure of personally identifiable information in financial applications
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision medium
 * @id java/pii-exposure-financial
 * @tags security
 *       external/rbi
 *       external/irdai
 *       privacy
 *       pii
 */

import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * PII fields commonly found in Indian financial applications
 */
class PIIField extends FieldAccess {
  PIIField() {
    this.getField().getName().toLowerCase().matches([
      // Indian specific identifiers
      "%aadhaar%", "%aadhar%", "%uid%", "%pan%", "%passport%",
      "%voter%id%", "%driving%license%", "%ration%card%",
      
      // Personal information
      "%phone%", "%mobile%", "%email%", "%address%", "%pincode%",
      "%name%", "%father%name%", "%mother%name%", "%spouse%name%",
      "%dob%", "%birth%date%", "%age%", "%gender%",
      
      // Financial PII
      "%salary%", "%income%", "%net%worth%", "%bank%balance%",
      "%credit%score%", "%loan%amount%", "%emi%",
      
      // Employment details
      "%employer%", "%designation%", "%company%", "%office%address%"
    ])
  }
}

/**
 * Methods that could expose PII to external systems
 */
class PIIExposureMethod extends Method {
  PIIExposureMethod() {
    // HTTP response methods
    this.getDeclaringType().hasQualifiedName([
      "javax.servlet.http", "org.springframework.web",
      "javax.ws.rs", "jakarta.ws.rs"
    ], _) and
    this.getName().matches(["write", "print", "send", "respond"])
    or
    // Logging methods
    this.getDeclaringType().hasQualifiedName([
      "org.slf4j", "org.apache.logging.log4j", "java.util.logging"
    ], _) and
    this.getName().matches(["debug", "info", "warn", "error", "trace"])
    or
    // External API calls
    this.getName().toLowerCase().matches([
      "%send%", "%post%", "%put%", "%transmit%", "%export%", "%sync%"
    ])
    or
    // Database operations without encryption
    this.getDeclaringType().getASupertype*().hasQualifiedName([
      "java.sql", "javax.persistence", "org.springframework.data"
    ], _) and
    this.getName().matches(["save", "persist", "insert", "update", "merge"])
  }
}

/**
 * Taint tracking configuration for PII exposure
 */
class PIIExposureConfig extends TaintTracking::Configuration {
  PIIExposureConfig() { this = "PIIExposureConfig" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof PIIField
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma |
      ma.getMethod() instanceof PIIExposureMethod and
      sink.asExpr() = ma.getAnArgument()
    )
    or
    // Return statements that might expose PII
    exists(ReturnStmt ret |
      ret.getResult() = sink.asExpr() and
      ret.getEnclosingCallable().isPublic()
    )
    or
    // Field assignments to public fields
    exists(Assignment assign |
      assign.getRhs() = sink.asExpr() and
      assign.getLhs().(FieldAccess).getField().isPublic()
    )
  }

  override predicate isSanitizer(DataFlow::Node node) {
    // PII is sanitized if it's encrypted, hashed, or masked
    exists(MethodAccess ma |
      ma.getMethod().getName().toLowerCase().matches([
        "%encrypt%", "%hash%", "%mask%", "%redact%", "%anonymize%",
        "%pseudonymize%", "%tokenize%", "%obfuscate%"
      ]) and
      node.asExpr() = ma
    )
    or
    // Data validation that checks for PII patterns
    exists(MethodAccess ma |
      ma.getMethod().getName().toLowerCase().matches([
        "%validate%pii%", "%check%sensitive%", "%filter%personal%"
      ]) and
      node.asExpr() = ma
    )
  }
}

/**
 * Check if the exposure is in a context that should be protected
 */
predicate isProtectedContext(DataFlow::Node sink) {
  // External API endpoints
  exists(Method m |
    m = sink.asExpr().getEnclosingCallable() and
    m.hasAnnotation("org.springframework.web.bind.annotation", [
      "RequestMapping", "GetMapping", "PostMapping", "PutMapping", "DeleteMapping"
    ])
  )
  or
  // Public methods that might be called externally
  exists(Method m |
    m = sink.asExpr().getEnclosingCallable() and
    m.isPublic() and
    m.getDeclaringType().isPublic()
  )
}

from PIIExposureConfig config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink) and
      isProtectedContext(sink.getNode())
select sink.getNode(), source, sink,
  "PII data from $@ may be exposed without proper protection, violating RBI data protection guidelines and privacy regulations.",
  source.getNode(), "this PII field"