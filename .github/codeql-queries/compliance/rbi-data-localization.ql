/**
 * @name RBI data localization compliance
 * @description Ensures financial data is processed and stored within India as per RBI guidelines
 * @kind problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id java/rbi-data-localization
 * @tags security
 *       external/rbi
 *       compliance
 *       data-localization
 */

import java

/**
 * Financial data that must be localized in India per RBI guidelines
 */
class FinancialData extends FieldAccess {
  FinancialData() {
    this.getField().getName().toLowerCase().matches([
      // Payment system data
      "%payment%", "%transaction%", "%settlement%", "%clearing%",
      "%card%data%", "%account%", "%balance%", "%fund%",
      
      // Customer financial information
      "%customer%data%", "%kyc%", "%credit%", "%loan%", "%deposit%",
      "%investment%", "%insurance%", "%pension%",
      
      // Regulatory reporting data
      "%regulatory%", "%compliance%", "%audit%", "%risk%data%"
    ])
    or
    this.getField().getType().getName().toLowerCase().matches([
      "%payment%", "%transaction%", "%account%", "%customer%"
    ])
  }
}

/**
 * Database connections that might store data outside India
 */
class DatabaseConnection extends MethodAccess {
  DatabaseConnection() {
    this.getMethod().hasName("getConnection") and
    this.getMethod().getDeclaringType().hasQualifiedName("java.sql", "DriverManager")
    or
    this.getMethod().hasName("createDataSource") and
    this.getMethod().getDeclaringType().getPackage().hasName([
      "org.springframework.boot.autoconfigure.jdbc",
      "org.apache.commons.dbcp2",
      "com.zaxxer.hikari"
    ])
  }
  
  string getConnectionUrl() {
    result = this.getArgument(0).(StringLiteral).getValue()
  }
}

/**
 * Cloud service configurations that might store data outside India
 */
class CloudServiceConfig extends MethodAccess {
  CloudServiceConfig() {
    // AWS configurations
    this.getMethod().getDeclaringType().getPackage().hasName("com.amazonaws") and
    this.getMethod().getName().matches(["withRegion", "setRegion", "region"])
    or
    // Azure configurations
    this.getMethod().getDeclaringType().getPackage().hasName("com.microsoft.azure") and
    this.getMethod().getName().matches(["withRegion", "setRegion", "location"])
    or
    // GCP configurations
    this.getMethod().getDeclaringType().getPackage().hasName("com.google.cloud") and
    this.getMethod().getName().matches(["setLocation", "setZone", "setRegion"])
  }
}

/**
 * External API calls that might transfer data outside India
 */
class ExternalAPICall extends MethodAccess {
  ExternalAPICall() {
    // HTTP client calls
    this.getMethod().getDeclaringType().hasQualifiedName([
      "org.apache.http.client", "okhttp3", "java.net.http"
    ], _) and
    this.getMethod().getName().matches(["execute", "send", "post", "put"])
    or
    // REST template calls
    this.getMethod().getDeclaringType().hasQualifiedName("org.springframework.web.client", "RestTemplate") and
    this.getMethod().getName().matches(["%ForEntity", "%ForObject", "exchange"])
  }
  
  string getTargetUrl() {
    exists(StringLiteral url |
      url = this.getAnArgument() and
      result = url.getValue()
    )
  }
}

/**
 * Check if a database URL indicates storage outside India
 */
predicate isNonIndianDatabase(string url) {
  // AWS regions outside India
  url.matches([
    "%us-east-%", "%us-west-%", "%eu-%", "%ap-southeast-%",
    "%ap-northeast-1%", "%ap-northeast-2%", "%ap-northeast-3%",
    "%ca-central-%", "%sa-east-%"
  ]) and
  not url.matches("%ap-south-1%") // Mumbai region is allowed
  or
  // Azure regions outside India
  url.matches([
    "%eastus%", "%westus%", "%northeurope%", "%westeurope%",
    "%eastasia%", "%southeastasia%", "%australiaeast%"
  ]) and
  not url.matches(["%centralindia%", "%southindia%", "%westindia%"])
  or
  // GCP regions outside India
  url.matches([
    "%us-central%", "%us-east%", "%us-west%", "%europe-%",
    "%asia-east%", "%asia-southeast%", "%australia-%"
  ]) and
  not url.matches("%asia-south%") // Mumbai region is allowed
  or
  // Generic non-Indian domains
  url.matches([
    "%.com%", "%.net%", "%.org%"
  ]) and
  not url.matches([
    "%.co.in%", "%.org.in%", "%.net.in%", "%.india.%", "%.mumbai.%"
  ])
}

/**
 * Check if an API URL indicates data transfer outside India
 */
predicate isNonIndianAPI(string url) {
  url.matches([
    "%://%.us%", "%://%.eu%", "%://%.asia%", "%://%.au%"
  ]) and
  not url.matches([
    "%://%.in%", "%://%.india%", "%mumbai%", "%delhi%",
    "%bangalore%", "%chennai%", "%hyderabad%", "%pune%"
  ])
}

from Expr violation, string issue, string location
where
  // Database connections outside India
  exists(DatabaseConnection db |
    violation = db and
    isNonIndianDatabase(db.getConnectionUrl()) and
    issue = "Database connection" and
    location = db.getConnectionUrl()
  )
  or
  // External API calls outside India that handle financial data
  exists(ExternalAPICall api |
    violation = api and
    isNonIndianAPI(api.getTargetUrl()) and
    exists(FinancialData fd |
      fd.getEnclosingCallable() = api.getEnclosingCallable()
    ) and
    issue = "External API call" and
    location = api.getTargetUrl()
  )
  or
  // Cloud service configurations outside India
  exists(CloudServiceConfig cloud, StringLiteral region |
    violation = cloud and
    region = cloud.getAnArgument() and
    not region.getValue().toLowerCase().matches([
      "%mumbai%", "%delhi%", "%india%", "%in%", "%ap-south-1%",
      "%centralindia%", "%southindia%", "%westindia%", "%asia-south%"
    ]) and
    issue = "Cloud service configuration" and
    location = region.getValue()
  )
select violation,
  issue + " at '" + location + "' may violate RBI data localization requirements. " +
  "All payment system data and customer information must be stored and processed within India. " +
  "Consider using Indian data centers or cloud regions (Mumbai/Delhi)."