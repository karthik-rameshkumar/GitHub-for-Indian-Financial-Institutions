# Prompt Engineering for Legacy Financial Systems

This guide provides specialized prompt engineering techniques for working with legacy financial systems using GitHub Copilot, focusing on mainframe integration, COBOL modernization, and API wrapper generation for BFSI environments.

## 🏛️ Overview

Legacy systems in Indian financial institutions often include:
- **Mainframe applications** running on IBM z/OS
- **COBOL programs** for core banking operations
- **DB2 databases** with complex schemas
- **Proprietary protocols** for inter-system communication
- **Legacy APIs** without modern documentation

## 🎯 Prompt Engineering Strategies

### 1. Context-Rich Prompts

When working with legacy systems, provide maximum context to get better suggestions:

```markdown
## Context Template for Legacy System Integration

**System Information:**
- Legacy System: [IBM z/OS Mainframe / AS/400 / Unix system]
- Programming Language: [COBOL / PL/I / Assembler / C]
- Database: [DB2 / IMS / VSAM / Oracle]
- Integration Method: [MQ Series / CICS / Batch files / REST APIs]

**Business Domain:**
- Function: [Core Banking / Payment Processing / Risk Management]
- Regulatory Requirements: [RBI / SEBI / IRDAI compliance]
- Data Sensitivity: [Customer PII / Financial transactions / Regulatory reporting]

**Technical Requirements:**
- Performance: [Transaction volume / Response time requirements]
- Security: [Encryption standards / Access controls / Audit requirements]
- Integration Pattern: [Real-time / Batch / Event-driven]
```

### 2. Legacy Code Pattern Recognition

```java
// Prompt: "Create a Java wrapper for this COBOL copybook structure"
// Context: Core banking customer record from mainframe

/**
 * COBOL Copybook: CUSTOMER-RECORD
 * 01 CUSTOMER-RECORD.
 *    05 CUST-ID           PIC 9(10).
 *    05 CUST-NAME         PIC X(50).
 *    05 CUST-TYPE         PIC X(02).
 *    05 ACCOUNT-BALANCE   PIC 9(13)V9(02) COMP-3.
 *    05 LAST-TXN-DATE     PIC 9(08).
 *    05 STATUS-CODE       PIC X(01).
 *    05 BRANCH-CODE       PIC 9(04).
 */

// Copilot will generate:
@Entity
@Table(name = "CUSTOMER_RECORDS")
public class CustomerRecord {
    
    @Id
    @Column(name = "CUST_ID", length = 10)
    private String customerId;
    
    @Column(name = "CUST_NAME", length = 50)
    private String customerName;
    
    @Column(name = "CUST_TYPE", length = 2)
    private String customerType;
    
    @Column(name = "ACCOUNT_BALANCE", precision = 15, scale = 2)
    private BigDecimal accountBalance;
    
    @Column(name = "LAST_TXN_DATE")
    @Temporal(TemporalType.DATE)
    private Date lastTransactionDate;
    
    @Column(name = "STATUS_CODE", length = 1)
    private String statusCode;
    
    @Column(name = "BRANCH_CODE", length = 4)
    private String branchCode;
    
    // Constructors, getters, setters, and validation methods
}
```

## 🔄 Mainframe Integration Patterns

### MQ Series Integration

```java
// Prompt: "Create MQ Series integration for mainframe payment processing"
// Context: Need to send payment instructions to COBOL program PYMTPROC

/**
 * Requirements:
 * - Connect to MQ Manager on mainframe
 * - Send payment request to queue PYMT.REQUEST.QUEUE
 * - Receive response from PYMT.RESPONSE.QUEUE
 * - Handle COBOL packed decimal fields
 * - Implement proper error handling and logging
 * - Ensure RBI compliance for payment processing
 */

@Service
@Slf4j
public class MainframePaymentService {
    
    @Autowired
    private JmsTemplate jmsTemplate;
    
    @Value("${mainframe.mq.request.queue}")
    private String requestQueue;
    
    @Value("${mainframe.mq.response.queue}")
    private String responseQueue;
    
    public PaymentResponse processPayment(PaymentRequest request) {
        try {
            // Convert Java object to COBOL-compatible format
            String cobolMessage = convertToCobolFormat(request);
            
            // Send to mainframe
            jmsTemplate.convertAndSend(requestQueue, cobolMessage, message -> {
                message.setJMSCorrelationID(UUID.randomUUID().toString());
                message.setJMSExpiration(30000); // 30 second timeout
                return message;
            });
            
            // Receive response
            Message response = jmsTemplate.receive(responseQueue);
            
            if (response instanceof TextMessage) {
                String responseText = ((TextMessage) response).getText();
                return parseCobolResponse(responseText);
            }
            
            throw new PaymentProcessingException("Invalid response format");
            
        } catch (JMSException e) {
            log.error("MQ communication error", e);
            throw new PaymentProcessingException("Mainframe communication failed", e);
        }
    }
    
    private String convertToCobolFormat(PaymentRequest request) {
        // Convert packed decimals and format fixed-length fields
        StringBuilder cobolRecord = new StringBuilder();
        
        // COBOL format: Fixed length fields, packed decimals
        cobolRecord.append(StringUtils.rightPad(request.getFromAccount(), 16));
        cobolRecord.append(StringUtils.rightPad(request.getToAccount(), 16));
        cobolRecord.append(formatPackedDecimal(request.getAmount(), 13, 2));
        cobolRecord.append(request.getTransactionDate().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        cobolRecord.append(StringUtils.rightPad(request.getCurrencyCode(), 3));
        
        return cobolRecord.toString();
    }
}
```

### CICS Transaction Integration

```java
// Prompt: "Create CICS transaction wrapper for account balance inquiry"
// Context: Legacy CICS transaction ACCT0001 for balance checking

/**
 * Legacy CICS Transaction: ACCT0001
 * Input: Customer ID (10 digits), Account Number (16 digits)
 * Output: Account Balance, Last Transaction Date, Status
 * Communication: CICS TG or CTG
 */

@Component
public class CicsAccountService {
    
    @Autowired
    private CicsConnectionManager connectionManager;
    
    public AccountBalanceResponse getAccountBalance(String customerId, String accountNumber) {
        ECIRequest eciRequest = new ECIRequest();
        
        try {
            // Set CICS transaction details
            eciRequest.setECITransactionName("ACCT0001");
            eciRequest.setECICommareaLength(64);
            
            // Prepare COMMAREA (Communication Area)
            CommAreaData commArea = new CommAreaData();
            commArea.setCustomerId(customerId);
            commArea.setAccountNumber(accountNumber);
            commArea.setTransactionCode("BAL");
            
            // Set request data
            eciRequest.setECICommarea(commArea.toByteArray());
            
            // Execute CICS transaction
            ECIInteraction interaction = connectionManager.getInteraction();
            interaction.execute(eciRequest);
            
            // Parse response
            byte[] responseData = eciRequest.getECICommarea();
            return parseBalanceResponse(responseData);
            
        } catch (Exception e) {
            log.error("CICS transaction failed for customer: {}", customerId, e);
            throw new LegacySystemException("Balance inquiry failed", e);
        }
    }
    
    private AccountBalanceResponse parseBalanceResponse(byte[] responseData) {
        // Parse COBOL data structure from response
        ByteArrayInputStream bis = new ByteArrayInputStream(responseData);
        
        AccountBalanceResponse response = new AccountBalanceResponse();
        response.setReturnCode(readFixedString(bis, 2));
        response.setAccountBalance(readPackedDecimal(bis, 13, 2));
        response.setLastTransactionDate(readDate(bis, 8));
        response.setAccountStatus(readFixedString(bis, 1));
        
        return response;
    }
}
```

## 📊 Database Integration Patterns

### DB2 Mainframe Queries

```java
// Prompt: "Create DB2 stored procedure call for customer risk assessment"
// Context: Legacy DB2 stored procedure RISK_CALC on mainframe

/**
 * DB2 Stored Procedure: RISK_CALC
 * Parameters:
 * - IN: Customer ID, Product Type, Loan Amount
 * - OUT: Risk Score, Risk Category, Approval Status
 * Database: DB2 for z/OS
 */

@Repository
public class LegacyRiskAssessmentDao {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    public RiskAssessmentResult calculateRisk(String customerId, String productType, BigDecimal loanAmount) {
        
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
            .withSchemaName("RISK_SCHEMA")
            .withProcedureName("RISK_CALC")
            .withoutProcedureColumnMetaDataAccess()
            .declareParameters(
                new SqlParameter("CUST_ID", Types.CHAR),
                new SqlParameter("PROD_TYPE", Types.CHAR),
                new SqlParameter("LOAN_AMT", Types.DECIMAL),
                new SqlOutParameter("RISK_SCORE", Types.DECIMAL),
                new SqlOutParameter("RISK_CATEGORY", Types.CHAR),
                new SqlOutParameter("APPROVAL_STATUS", Types.CHAR),
                new SqlOutParameter("RETURN_CODE", Types.CHAR)
            );
        
        SqlParameterSource params = new MapSqlParameterSource()
            .addValue("CUST_ID", StringUtils.rightPad(customerId, 10))
            .addValue("PROD_TYPE", StringUtils.rightPad(productType, 5))
            .addValue("LOAN_AMT", loanAmount);
        
        Map<String, Object> result = jdbcCall.execute(params);
        
        // Check return code
        String returnCode = (String) result.get("RETURN_CODE");
        if (!"00".equals(returnCode.trim())) {
            throw new RiskCalculationException("Risk calculation failed: " + returnCode);
        }
        
        return RiskAssessmentResult.builder()
            .riskScore((BigDecimal) result.get("RISK_SCORE"))
            .riskCategory(((String) result.get("RISK_CATEGORY")).trim())
            .approvalStatus(((String) result.get("APPROVAL_STATUS")).trim())
            .build();
    }
}
```

### VSAM File Access

```java
// Prompt: "Create Java interface for VSAM customer master file"
// Context: VSAM KSDS file with customer master records

/**
 * VSAM File: CUSTMAST.VSAM.KSDS
 * Key: Customer ID (10 bytes)
 * Record Length: 500 bytes
 * Access: Sequential and Random
 */

@Service
public class VsamCustomerService {
    
    @Value("${vsam.customer.dataset}")
    private String vsamDataset;
    
    @Autowired
    private VsamConnectionManager vsamManager;
    
    public CustomerMasterRecord getCustomer(String customerId) {
        try {
            VsamDataset dataset = vsamManager.openDataset(vsamDataset, VsamAccessMode.READ);
            
            // Position to record using key
            VsamKey key = new VsamKey(customerId.getBytes());
            VsamRecord record = dataset.read(key);
            
            if (record != null) {
                return parseCustomerRecord(record.getData());
            }
            
            return null;
            
        } catch (VsamException e) {
            log.error("VSAM read error for customer: {}", customerId, e);
            throw new LegacyDataException("Failed to read customer data", e);
        }
    }
    
    public void updateCustomer(CustomerMasterRecord customer) {
        try {
            VsamDataset dataset = vsamManager.openDataset(vsamDataset, VsamAccessMode.UPDATE);
            
            byte[] recordData = formatCustomerRecord(customer);
            VsamKey key = new VsamKey(customer.getCustomerId().getBytes());
            
            dataset.update(key, recordData);
            
        } catch (VsamException e) {
            log.error("VSAM update error for customer: {}", customer.getCustomerId(), e);
            throw new LegacyDataException("Failed to update customer data", e);
        }
    }
    
    private CustomerMasterRecord parseCustomerRecord(byte[] data) {
        // Parse fixed-length COBOL record structure
        ByteBuffer buffer = ByteBuffer.wrap(data);
        
        CustomerMasterRecord record = new CustomerMasterRecord();
        record.setCustomerId(readString(buffer, 10).trim());
        record.setCustomerName(readString(buffer, 50).trim());
        record.setDateOfBirth(readDate(buffer, 8));
        record.setAccountOpenDate(readDate(buffer, 8));
        record.setCustomerType(readString(buffer, 2).trim());
        record.setBranchCode(readString(buffer, 4).trim());
        
        return record;
    }
}
```

## 🔌 API Wrapper Generation

### Legacy Web Service Integration

```java
// Prompt: "Create modern REST wrapper for legacy SOAP service"
// Context: Legacy payment processing SOAP service needs REST interface

/**
 * Legacy SOAP Service: PaymentProcessingService
 * WSDL: http://mainframe.bank.internal:8080/PaymentService?wsdl
 * Operations: ProcessPayment, ValidateAccount, GetTransactionStatus
 * Requirements: Convert to REST API with proper error handling
 */

@RestController
@RequestMapping("/api/v1/payments")
@Slf4j
public class PaymentApiController {
    
    @Autowired
    private LegacyPaymentServiceClient legacyClient;
    
    @PostMapping("/process")
    @Operation(summary = "Process payment through legacy system")
    public ResponseEntity<PaymentResponse> processPayment(
            @Valid @RequestBody PaymentRequest request) {
        
        try {
            // Convert REST request to SOAP format
            ProcessPaymentRequest soapRequest = convertToSoapRequest(request);
            
            // Call legacy SOAP service
            ProcessPaymentResponse soapResponse = legacyClient.processPayment(soapRequest);
            
            // Convert SOAP response to REST format
            PaymentResponse restResponse = convertToRestResponse(soapResponse);
            
            // Add modern fields
            restResponse.setTimestamp(Instant.now());
            restResponse.setApiVersion("1.0");
            
            return ResponseEntity.ok(restResponse);
            
        } catch (LegacyServiceException e) {
            log.error("Legacy payment service error", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(PaymentResponse.error("Legacy system unavailable"));
        }
    }
    
    @GetMapping("/validate/{accountNumber}")
    public ResponseEntity<AccountValidationResponse> validateAccount(
            @PathVariable String accountNumber) {
        
        ValidateAccountRequest soapRequest = new ValidateAccountRequest();
        soapRequest.setAccountNumber(accountNumber);
        
        ValidateAccountResponse soapResponse = legacyClient.validateAccount(soapRequest);
        
        AccountValidationResponse response = AccountValidationResponse.builder()
            .accountNumber(accountNumber)
            .isValid(soapResponse.isValid())
            .accountType(soapResponse.getAccountType())
            .branchCode(soapResponse.getBranchCode())
            .validationTimestamp(Instant.now())
            .build();
            
        return ResponseEntity.ok(response);
    }
}
```

## 🧪 Testing Legacy Integrations

### Mock Legacy System Responses

```java
// Prompt: "Create comprehensive test suite for legacy system integration"
// Context: Need to test mainframe integration without actual mainframe access

@TestConfiguration
public class LegacySystemTestConfig {
    
    @Bean
    @Primary
    @Profile("test")
    public LegacyPaymentServiceClient mockLegacyClient() {
        return Mockito.mock(LegacyPaymentServiceClient.class);
    }
}

@SpringBootTest
@ActiveProfiles("test")
class LegacyPaymentServiceTest {
    
    @Autowired
    private PaymentApiController paymentController;
    
    @MockBean
    private LegacyPaymentServiceClient legacyClient;
    
    @Test
    void shouldProcessPaymentSuccessfully() {
        // Given
        PaymentRequest request = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.00"))
            .currency("INR")
            .build();
            
        ProcessPaymentResponse mockResponse = new ProcessPaymentResponse();
        mockResponse.setTransactionId("TXN123456789");
        mockResponse.setStatus("SUCCESS");
        mockResponse.setProcessingTime("00:00:02");
        
        when(legacyClient.processPayment(any())).thenReturn(mockResponse);
        
        // When
        ResponseEntity<PaymentResponse> response = paymentController.processPayment(request);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getTransactionId()).isEqualTo("TXN123456789");
        assertThat(response.getBody().getStatus()).isEqualTo("SUCCESS");
    }
    
    @Test
    void shouldHandleLegacySystemFailure() {
        // Given
        PaymentRequest request = createValidPaymentRequest();
        
        when(legacyClient.processPayment(any()))
            .thenThrow(new LegacyServiceException("Connection timeout"));
        
        // When
        ResponseEntity<PaymentResponse> response = paymentController.processPayment(request);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getBody().getError()).contains("Legacy system unavailable");
    }
}
```

## 🎯 Effective Prompting Techniques

### 1. Legacy Code Translation

```markdown
**Prompt Template:**
"Convert this COBOL code to Java Spring Boot service:

```cobol
[COBOL CODE HERE]
```

Requirements:
- Use Spring Boot best practices
- Add proper error handling
- Include unit tests
- Ensure RBI compliance for financial data
- Add audit logging
- Use BigDecimal for monetary amounts"
```

### 2. Data Structure Mapping

```markdown
**Prompt Template:**
"Create JPA entity from this mainframe copybook:

```cobol
[COPYBOOK STRUCTURE]
```

Requirements:
- Map COBOL data types to Java types correctly
- Handle packed decimals properly
- Add validation annotations
- Include audit fields
- Add database constraints for BFSI compliance"
```

### 3. Integration Pattern Implementation

```markdown
**Prompt Template:**
"Implement [INTEGRATION_PATTERN] for legacy system integration:

System: [SYSTEM_TYPE]
Protocol: [COMMUNICATION_PROTOCOL]
Business Function: [BUSINESS_DOMAIN]

Requirements:
- Handle [SPECIFIC_DATA_FORMATS]
- Implement proper error handling
- Add circuit breaker pattern
- Include comprehensive logging
- Ensure [REGULATORY_COMPLIANCE]"
```

## 📚 Best Practices

### 1. Context Preservation

```java
// Always provide context about:
// - Legacy system architecture
// - Data formats and encoding
// - Business rules and constraints
// - Regulatory requirements
// - Performance expectations
```

### 2. Error Handling Patterns

```java
// Prompt: "Add comprehensive error handling for legacy system integration"

@ControllerAdvice
public class LegacySystemExceptionHandler {
    
    @ExceptionHandler(LegacyServiceException.class)
    public ResponseEntity<ErrorResponse> handleLegacyServiceException(
            LegacyServiceException e) {
        
        ErrorResponse error = ErrorResponse.builder()
            .errorCode("LEGACY_SYSTEM_ERROR")
            .message("Legacy system temporarily unavailable")
            .timestamp(Instant.now())
            .correlationId(MDC.get("correlationId"))
            .build();
            
        // Log for audit trail
        log.error("Legacy system error: {}", e.getMessage(), e);
        
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
            .body(error);
    }
}
```

### 3. Performance Optimization

```java
// Prompt: "Optimize legacy system calls with caching and batching"

@Service
public class OptimizedLegacyService {
    
    @Cacheable(value = "customerCache", key = "#customerId")
    public CustomerData getCustomer(String customerId) {
        return legacyService.getCustomer(customerId);
    }
    
    @Async
    @Retryable(value = {LegacyServiceException.class}, maxAttempts = 3)
    public CompletableFuture<List<AccountData>> getAccountsBatch(List<String> accountNumbers) {
        return CompletableFuture.completedFuture(
            legacyService.getAccountsBatch(accountNumbers)
        );
    }
}
```

## 🔧 Tools and Utilities

### Legacy Data Converter

```java
// Prompt: "Create utility for converting between COBOL and Java data types"

@Component
public class CobolDataConverter {
    
    public BigDecimal convertPackedDecimal(byte[] packedData, int precision, int scale) {
        // Implementation for COBOL packed decimal conversion
    }
    
    public String convertCobolDate(String cobolDate, String format) {
        // Convert COBOL date formats (YYYYMMDD, YYMMDD, etc.)
    }
    
    public byte[] convertJavaToCobol(Object javaObject, CobolLayout layout) {
        // Convert Java object to COBOL fixed-length record
    }
}
```

---

**Next Steps**: Proceed to [Test Case Generation Examples](../examples/test-generation.md) to learn automated test creation for payment validation modules.