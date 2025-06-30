# Test Case Generation Examples for Payment Validation

This guide demonstrates how to use GitHub Copilot to generate comprehensive test cases for payment validation modules in BFSI applications, ensuring compliance with Indian banking regulations and international standards.

## 🏛️ Overview

Payment validation testing in BFSI requires:
- **Regulatory Compliance**: RBI, NPCI, and international standards
- **Security Testing**: Fraud detection and prevention
- **Performance Testing**: High-volume transaction processing
- **Error Handling**: Comprehensive failure scenario coverage
- **Data Validation**: PII protection and data integrity

## 🎯 Payment Validation Test Categories

### 1. Basic Payment Validation Tests

```java
// Prompt: "Generate comprehensive test cases for basic payment validation"
// Context: Payment validation service with amount, account, and regulatory checks

@SpringBootTest
@TestMethodOrder(OrderAnnotation.class)
class PaymentValidationServiceTest {
    
    @Autowired
    private PaymentValidationService validationService;
    
    @MockBean
    private AccountService accountService;
    
    @MockBean
    private RegulatoryComplianceService complianceService;
    
    @Test
    @Order(1)
    @DisplayName("Should validate successful payment with valid inputs")
    void shouldValidateSuccessfulPayment() {
        // Given
        PaymentRequest request = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("5000.00"))
            .currency("INR")
            .purpose("SALARY")
            .build();
            
        when(accountService.isValidAccount("1234567890123456")).thenReturn(true);
        when(accountService.isValidAccount("9876543210987654")).thenReturn(true);
        when(accountService.hasSufficientBalance("1234567890123456", new BigDecimal("5000.00")))
            .thenReturn(true);
        when(complianceService.isTransactionCompliant(any())).thenReturn(true);
        
        // When
        ValidationResult result = validationService.validatePayment(request);
        
        // Then
        assertThat(result.isValid()).isTrue();
        assertThat(result.getErrors()).isEmpty();
        assertThat(result.getWarnings()).isEmpty();
    }
    
    @Test
    @Order(2)
    @DisplayName("Should reject payment with invalid from account")
    void shouldRejectPaymentWithInvalidFromAccount() {
        // Given
        PaymentRequest request = PaymentRequest.builder()
            .fromAccount("INVALID_ACCOUNT")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.00"))
            .currency("INR")
            .build();
            
        when(accountService.isValidAccount("INVALID_ACCOUNT")).thenReturn(false);
        
        // When
        ValidationResult result = validationService.validatePayment(request);
        
        // Then
        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors()).contains("Invalid from account number");
        assertThat(result.getErrorCode()).isEqualTo("INVALID_FROM_ACCOUNT");
    }
    
    @Test
    @Order(3)
    @DisplayName("Should reject payment exceeding daily limit")
    void shouldRejectPaymentExceedingDailyLimit() {
        // Given
        PaymentRequest request = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("200001.00")) // Exceeds ₹2,00,000 daily limit
            .currency("INR")
            .build();
            
        when(accountService.isValidAccount(anyString())).thenReturn(true);
        when(accountService.hasSufficientBalance(anyString(), any())).thenReturn(true);
        when(accountService.getDailyTransactionAmount("1234567890123456"))
            .thenReturn(new BigDecimal("200001.00"));
        
        // When
        ValidationResult result = validationService.validatePayment(request);
        
        // Then
        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors()).contains("Daily transaction limit exceeded");
        assertThat(result.getErrorCode()).isEqualTo("DAILY_LIMIT_EXCEEDED");
    }
}
```

### 2. RBI Compliance Validation Tests

```java
// Prompt: "Generate test cases for RBI payment compliance validation"
// Context: RBI guidelines for digital payments and transaction monitoring

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class RBIComplianceValidationTest {
    
    @Autowired
    private RBIComplianceValidator rbiValidator;
    
    @Test
    @DisplayName("Should validate RTGS transaction compliance")
    void shouldValidateRTGSTransactionCompliance() {
        // Given - RTGS minimum amount ₹2,00,000
        PaymentRequest rtgsRequest = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("200000.00"))
            .currency("INR")
            .paymentMode("RTGS")
            .purpose("BUSINESS_PAYMENT")
            .build();
        
        // When
        ComplianceResult result = rbiValidator.validatePayment(rtgsRequest);
        
        // Then
        assertThat(result.isCompliant()).isTrue();
        assertThat(result.getPaymentMode()).isEqualTo("RTGS");
        assertThat(result.getComplianceScore()).isGreaterThan(95);
    }
    
    @Test
    @DisplayName("Should reject RTGS transaction below minimum amount")
    void shouldRejectRTGSBelowMinimumAmount() {
        // Given - Amount below RTGS minimum
        PaymentRequest request = PaymentRequest.builder()
            .amount(new BigDecimal("199999.00"))
            .paymentMode("RTGS")
            .currency("INR")
            .build();
        
        // When
        ComplianceResult result = rbiValidator.validatePayment(request);
        
        // Then
        assertThat(result.isCompliant()).isFalse();
        assertThat(result.getViolations()).contains("RTGS minimum amount not met");
        assertThat(result.getRecommendedMode()).isEqualTo("NEFT");
    }
    
    @Test
    @DisplayName("Should validate NEFT transaction timing")
    void shouldValidateNEFTTransactionTiming() {
        // Given - NEFT during business hours
        LocalDateTime businessHour = LocalDateTime.of(2024, 1, 15, 14, 30); // Monday 2:30 PM
        
        PaymentRequest neftRequest = PaymentRequest.builder()
            .amount(new BigDecimal("50000.00"))
            .paymentMode("NEFT")
            .scheduledTime(businessHour)
            .build();
        
        // When
        ComplianceResult result = rbiValidator.validatePayment(neftRequest);
        
        // Then
        assertThat(result.isCompliant()).isTrue();
        assertThat(result.getProcessingWindow()).isEqualTo("IMMEDIATE");
    }
    
    @Test
    @DisplayName("Should handle NEFT outside business hours")
    void shouldHandleNEFTOutsideBusinessHours() {
        // Given - NEFT outside business hours
        LocalDateTime afterHours = LocalDateTime.of(2024, 1, 15, 22, 30); // Monday 10:30 PM
        
        PaymentRequest request = PaymentRequest.builder()
            .amount(new BigDecimal("25000.00"))
            .paymentMode("NEFT")
            .scheduledTime(afterHours)
            .build();
        
        // When
        ComplianceResult result = rbiValidator.validatePayment(request);
        
        // Then
        assertThat(result.isCompliant()).isTrue();
        assertThat(result.getProcessingWindow()).isEqualTo("NEXT_BUSINESS_DAY");
        assertThat(result.getWarnings()).contains("Transaction scheduled for next business day");
    }
    
    @ParameterizedTest
    @ValueSource(strings = {"IMPS", "UPI", "NEFT", "RTGS"})
    @DisplayName("Should validate payment mode specific limits")
    void shouldValidatePaymentModeSpecificLimits(String paymentMode) {
        // Given
        BigDecimal testAmount = getTestAmountForMode(paymentMode);
        
        PaymentRequest request = PaymentRequest.builder()
            .amount(testAmount)
            .paymentMode(paymentMode)
            .currency("INR")
            .build();
        
        // When
        ComplianceResult result = rbiValidator.validatePayment(request);
        
        // Then
        assertThat(result.isCompliant()).isTrue();
        assertThat(result.getApplicableLimits()).isNotEmpty();
        assertThat(result.getPaymentMode()).isEqualTo(paymentMode);
    }
    
    private BigDecimal getTestAmountForMode(String mode) {
        return switch (mode) {
            case "IMPS" -> new BigDecimal("200000.00");  // IMPS limit
            case "UPI" -> new BigDecimal("100000.00");   // UPI limit
            case "NEFT" -> new BigDecimal("50000.00");   // Test amount for NEFT
            case "RTGS" -> new BigDecimal("500000.00");  // Test amount for RTGS
            default -> new BigDecimal("10000.00");
        };
    }
}
```

### 3. Fraud Detection and Security Tests

```java
// Prompt: "Create comprehensive fraud detection test cases for payment validation"
// Context: ML-based fraud detection with velocity checks and pattern analysis

@SpringBootTest
@Sql(scripts = "/test-data/fraud-detection-data.sql")
class FraudDetectionValidationTest {
    
    @Autowired
    private FraudDetectionService fraudDetectionService;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    @DisplayName("Should detect suspicious velocity patterns")
    void shouldDetectSuspiciousVelocityPatterns() {
        // Given - Multiple rapid transactions
        String accountNumber = "1234567890123456";
        List<PaymentRequest> rapidTransactions = createRapidTransactionSequence(accountNumber, 10);
        
        // When
        List<FraudScore> scores = rapidTransactions.stream()
            .map(request -> fraudDetectionService.assessFraudRisk(request))
            .collect(Collectors.toList());
        
        // Then
        assertThat(scores.get(0).getRiskLevel()).isEqualTo(RiskLevel.LOW);
        assertThat(scores.get(4).getRiskLevel()).isEqualTo(RiskLevel.MEDIUM);
        assertThat(scores.get(9).getRiskLevel()).isEqualTo(RiskLevel.HIGH);
        
        // Verify fraud indicators
        FraudScore highRiskScore = scores.get(9);
        assertThat(highRiskScore.getIndicators()).contains("VELOCITY_ANOMALY");
        assertThat(highRiskScore.getScore()).isGreaterThan(0.8);
    }
    
    @Test
    @DisplayName("Should detect unusual transaction amounts")
    void shouldDetectUnusualTransactionAmounts() {
        // Given - Account with typical transaction pattern
        String accountNumber = "1234567890123456";
        setupTypicalTransactionHistory(accountNumber);
        
        // Unusual large transaction
        PaymentRequest unusualTransaction = PaymentRequest.builder()
            .fromAccount(accountNumber)
            .toAccount("9876543210987654")
            .amount(new BigDecimal("500000.00")) // Much higher than usual
            .currency("INR")
            .build();
        
        // When
        FraudScore fraudScore = fraudDetectionService.assessFraudRisk(unusualTransaction);
        
        // Then
        assertThat(fraudScore.getRiskLevel()).isEqualTo(RiskLevel.HIGH);
        assertThat(fraudScore.getIndicators()).contains("AMOUNT_ANOMALY");
        assertThat(fraudScore.getConfidenceLevel()).isGreaterThan(0.7);
    }
    
    @Test
    @DisplayName("Should detect geolocation anomalies")
    void shouldDetectGeolocationAnomalies() {
        // Given - User with established location pattern
        String customerId = "CUST123456";
        TransactionContext mumbaiContext = TransactionContext.builder()
            .customerId(customerId)
            .ipAddress("203.192.XXX.XXX") // Mumbai IP
            .deviceFingerprint("KNOWN_DEVICE_001")
            .location(new GeoLocation(19.0760, 72.8777)) // Mumbai coordinates
            .build();
        
        TransactionContext delhiContext = TransactionContext.builder()
            .customerId(customerId)
            .ipAddress("157.119.XXX.XXX") // Delhi IP
            .deviceFingerprint("UNKNOWN_DEVICE_002")
            .location(new GeoLocation(28.6139, 77.2090)) // Delhi coordinates
            .transactionTime(LocalDateTime.now())
            .build();
        
        // When
        FraudScore mumbaiScore = fraudDetectionService.assessLocationRisk(mumbaiContext);
        FraudScore delhiScore = fraudDetectionService.assessLocationRisk(delhiContext);
        
        // Then
        assertThat(mumbaiScore.getRiskLevel()).isEqualTo(RiskLevel.LOW);
        assertThat(delhiScore.getRiskLevel()).isEqualTo(RiskLevel.HIGH);
        assertThat(delhiScore.getIndicators()).contains("LOCATION_ANOMALY", "DEVICE_ANOMALY");
    }
    
    @Test
    @DisplayName("Should validate beneficiary reputation")
    void shouldValidateBeneficiaryReputation() {
        // Given
        PaymentRequest toKnownBeneficiary = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654") // Known good beneficiary
            .amount(new BigDecimal("10000.00"))
            .build();
            
        PaymentRequest toSuspiciousBeneficiary = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("1111111111111111") // Flagged account
            .amount(new BigDecimal("10000.00"))
            .build();
        
        // When
        FraudScore knownScore = fraudDetectionService.assessFraudRisk(toKnownBeneficiary);
        FraudScore suspiciousScore = fraudDetectionService.assessFraudRisk(toSuspiciousBeneficiary);
        
        // Then
        assertThat(knownScore.getRiskLevel()).isEqualTo(RiskLevel.LOW);
        assertThat(suspiciousScore.getRiskLevel()).isEqualTo(RiskLevel.HIGH);
        assertThat(suspiciousScore.getIndicators()).contains("SUSPICIOUS_BENEFICIARY");
    }
    
    private List<PaymentRequest> createRapidTransactionSequence(String fromAccount, int count) {
        List<PaymentRequest> transactions = new ArrayList<>();
        LocalDateTime baseTime = LocalDateTime.now().minusMinutes(30);
        
        for (int i = 0; i < count; i++) {
            transactions.add(PaymentRequest.builder()
                .fromAccount(fromAccount)
                .toAccount("BENEFICIARY_" + i)
                .amount(new BigDecimal("5000.00"))
                .timestamp(baseTime.plusMinutes(i * 2)) // Every 2 minutes
                .build());
        }
        
        return transactions;
    }
}
```

### 4. Performance and Load Testing

```java
// Prompt: "Generate performance test cases for high-volume payment processing"
// Context: Payment validation must handle peak loads during festival seasons

@SpringBootTest
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class PaymentValidationPerformanceTest {
    
    @Autowired
    private PaymentValidationService validationService;
    
    @Test
    @DisplayName("Should handle concurrent payment validations")
    void shouldHandleConcurrentPaymentValidations() throws InterruptedException {
        // Given
        int concurrentRequests = 100;
        CountDownLatch latch = new CountDownLatch(concurrentRequests);
        ExecutorService executor = Executors.newFixedThreadPool(20);
        List<CompletableFuture<ValidationResult>> futures = new ArrayList<>();
        
        // When
        long startTime = System.currentTimeMillis();
        
        for (int i = 0; i < concurrentRequests; i++) {
            PaymentRequest request = createTestPaymentRequest(i);
            
            CompletableFuture<ValidationResult> future = CompletableFuture.supplyAsync(() -> {
                try {
                    return validationService.validatePayment(request);
                } finally {
                    latch.countDown();
                }
            }, executor);
            
            futures.add(future);
        }
        
        latch.await(30, TimeUnit.SECONDS);
        long endTime = System.currentTimeMillis();
        
        // Then
        List<ValidationResult> results = futures.stream()
            .map(CompletableFuture::join)
            .collect(Collectors.toList());
        
        assertThat(results).hasSize(concurrentRequests);
        assertThat(results.stream().allMatch(r -> r != null)).isTrue();
        
        long totalTime = endTime - startTime;
        double avgResponseTime = (double) totalTime / concurrentRequests;
        
        // Performance assertions
        assertThat(avgResponseTime).isLessThan(100.0); // Less than 100ms average
        assertThat(totalTime).isLessThan(5000); // Total time less than 5 seconds
        
        executor.shutdown();
    }
    
    @Test
    @DisplayName("Should maintain performance under memory pressure")
    @Timeout(value = 60, unit = TimeUnit.SECONDS)
    void shouldMaintainPerformanceUnderMemoryPressure() {
        // Given - Create memory pressure
        List<byte[]> memoryHog = new ArrayList<>();
        for (int i = 0; i < 1000; i++) {
            memoryHog.add(new byte[1024 * 1024]); // 1MB each
        }
        
        // When
        long startTime = System.nanoTime();
        
        for (int i = 0; i < 1000; i++) {
            PaymentRequest request = createTestPaymentRequest(i);
            ValidationResult result = validationService.validatePayment(request);
            assertThat(result).isNotNull();
        }
        
        long endTime = System.nanoTime();
        double avgTime = (endTime - startTime) / 1_000_000.0 / 1000; // Convert to ms per operation
        
        // Then
        assertThat(avgTime).isLessThan(50.0); // Less than 50ms per validation
        
        // Cleanup
        memoryHog.clear();
        System.gc();
    }
    
    @ParameterizedTest
    @ValueSource(ints = {10, 50, 100, 500, 1000})
    @DisplayName("Should scale validation performance linearly")
    void shouldScaleValidationPerformanceLinearly(int requestCount) {
        // Given
        List<PaymentRequest> requests = IntStream.range(0, requestCount)
            .mapToObj(this::createTestPaymentRequest)
            .collect(Collectors.toList());
        
        // When
        long startTime = System.nanoTime();
        
        List<ValidationResult> results = requests.parallelStream()
            .map(validationService::validatePayment)
            .collect(Collectors.toList());
        
        long endTime = System.nanoTime();
        double totalTime = (endTime - startTime) / 1_000_000.0; // Convert to milliseconds
        
        // Then
        assertThat(results).hasSize(requestCount);
        
        double throughput = requestCount / (totalTime / 1000.0); // Requests per second
        
        // Throughput should be at least 100 requests per second
        assertThat(throughput).isGreaterThan(100.0);
        
        log.info("Processed {} requests in {}ms (throughput: {} req/sec)", 
                requestCount, totalTime, throughput);
    }
    
    private PaymentRequest createTestPaymentRequest(int index) {
        return PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("987654321098765" + (index % 10))
            .amount(new BigDecimal(1000 + (index % 1000)))
            .currency("INR")
            .purpose("TEST_PAYMENT_" + index)
            .build();
    }
}
```

### 5. Edge Cases and Error Handling Tests

```java
// Prompt: "Create comprehensive edge case tests for payment validation"
// Context: Handle all possible error scenarios and edge conditions

@TestMethodOrder(OrderAnnotation.class)
class PaymentValidationEdgeCasesTest {
    
    @Autowired
    private PaymentValidationService validationService;
    
    @Test
    @Order(1)
    @DisplayName("Should handle null and empty inputs gracefully")
    void shouldHandleNullAndEmptyInputsGracefully() {
        // Test null request
        assertThatThrownBy(() -> validationService.validatePayment(null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Payment request cannot be null");
        
        // Test empty account numbers
        PaymentRequest emptyFromAccount = PaymentRequest.builder()
            .fromAccount("")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.00"))
            .build();
            
        ValidationResult result = validationService.validatePayment(emptyFromAccount);
        assertThat(result.isValid()).isFalse();
        assertThat(result.getErrors()).contains("From account number cannot be empty");
    }
    
    @Test
    @Order(2)
    @DisplayName("Should handle extreme decimal amounts")
    void shouldHandleExtremeDecimalAmounts() {
        // Test very small amount
        PaymentRequest smallAmount = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("0.01"))
            .currency("INR")
            .build();
            
        ValidationResult smallResult = validationService.validatePayment(smallAmount);
        assertThat(smallResult.isValid()).isTrue();
        
        // Test amount with many decimal places
        PaymentRequest preciseAmount = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.123456789"))
            .currency("INR")
            .build();
            
        ValidationResult preciseResult = validationService.validatePayment(preciseAmount);
        assertThat(preciseResult.isValid()).isFalse();
        assertThat(preciseResult.getErrors()).contains("Amount cannot have more than 2 decimal places");
    }
    
    @Test
    @Order(3)
    @DisplayName("Should handle currency validation edge cases")
    void shouldHandleCurrencyValidationEdgeCases() {
        List<TestCase> currencyTests = Arrays.asList(
            new TestCase("INR", true, "Valid Indian Rupee"),
            new TestCase("USD", false, "Foreign currency not allowed"),
            new TestCase("XYZ", false, "Invalid currency code"),
            new TestCase("", false, "Empty currency"),
            new TestCase(null, false, "Null currency"),
            new TestCase("inr", false, "Lowercase currency code")
        );
        
        currencyTests.forEach(testCase -> {
            PaymentRequest request = PaymentRequest.builder()
                .fromAccount("1234567890123456")
                .toAccount("9876543210987654")
                .amount(new BigDecimal("1000.00"))
                .currency(testCase.currency)
                .build();
                
            ValidationResult result = validationService.validatePayment(request);
            
            assertThat(result.isValid())
                .as("Currency validation for: %s", testCase.description)
                .isEqualTo(testCase.expectedValid);
        });
    }
    
    @Test
    @Order(4)
    @DisplayName("Should handle account number format variations")
    void shouldHandleAccountNumberFormatVariations() {
        Map<String, Boolean> accountTests = Map.of(
            "1234567890123456", true,           // Valid 16-digit account
            "12345678901234567890", true,       // Valid 20-digit account
            "123456789012345", false,           // Too short (15 digits)
            "123456789012345678901", false,     // Too long (21 digits)
            "123456789012345A", false,          // Contains letter
            "1234-5678-9012-3456", false,       // Contains hyphens
            " 1234567890123456 ", false,        // Contains spaces
            "", false,                          // Empty
            "0000000000000000", false           // All zeros
        );
        
        accountTests.forEach((account, expectedValid) -> {
            PaymentRequest request = PaymentRequest.builder()
                .fromAccount(account)
                .toAccount("9876543210987654")
                .amount(new BigDecimal("1000.00"))
                .currency("INR")
                .build();
                
            ValidationResult result = validationService.validatePayment(request);
            
            assertThat(result.isValid())
                .as("Account number validation for: %s", account)
                .isEqualTo(expectedValid);
        });
    }
    
    @Test
    @Order(5)
    @DisplayName("Should handle boundary values for transaction limits")
    void shouldHandleBoundaryValuesForTransactionLimits() {
        // Test exact limit boundaries
        List<BoundaryTest> boundaryTests = Arrays.asList(
            // IMPS limits
            new BoundaryTest(new BigDecimal("200000.00"), "IMPS", true, "IMPS exact limit"),
            new BoundaryTest(new BigDecimal("200000.01"), "IMPS", false, "IMPS over limit"),
            new BoundaryTest(new BigDecimal("199999.99"), "IMPS", true, "IMPS under limit"),
            
            // UPI limits
            new BoundaryTest(new BigDecimal("100000.00"), "UPI", true, "UPI exact limit"),
            new BoundaryTest(new BigDecimal("100000.01"), "UPI", false, "UPI over limit"),
            
            // RTGS minimum
            new BoundaryTest(new BigDecimal("200000.00"), "RTGS", true, "RTGS minimum"),
            new BoundaryTest(new BigDecimal("199999.99"), "RTGS", false, "RTGS below minimum")
        );
        
        boundaryTests.forEach(test -> {
            PaymentRequest request = PaymentRequest.builder()
                .fromAccount("1234567890123456")
                .toAccount("9876543210987654")
                .amount(test.amount)
                .paymentMode(test.paymentMode)
                .currency("INR")
                .build();
                
            ValidationResult result = validationService.validatePayment(request);
            
            assertThat(result.isValid())
                .as(test.description)
                .isEqualTo(test.expectedValid);
        });
    }
    
    @Test
    @Order(6)
    @DisplayName("Should handle weekend and holiday validations")
    void shouldHandleWeekendAndHolidayValidations() {
        // Test Saturday (weekend)
        LocalDateTime saturday = LocalDateTime.of(2024, 6, 1, 14, 30); // Saturday 2:30 PM
        
        PaymentRequest weekendRequest = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("50000.00"))
            .paymentMode("NEFT")
            .scheduledTime(saturday)
            .build();
            
        ValidationResult weekendResult = validationService.validatePayment(weekendRequest);
        
        assertThat(weekendResult.isValid()).isTrue();
        assertThat(weekendResult.getWarnings()).contains("Transaction scheduled for next working day");
        
        // Test national holiday (Independence Day)
        LocalDateTime independenceDay = LocalDateTime.of(2024, 8, 15, 14, 30); // Aug 15, 2:30 PM
        
        PaymentRequest holidayRequest = PaymentRequest.builder()
            .fromAccount("1234567890123456")
            .toAccount("9876543210987654")
            .amount(new BigDecimal("25000.00"))
            .paymentMode("NEFT")
            .scheduledTime(independenceDay)
            .build();
            
        ValidationResult holidayResult = validationService.validatePayment(holidayRequest);
        
        assertThat(holidayResult.isValid()).isTrue();
        assertThat(holidayResult.getWarnings()).contains("Transaction scheduled for next working day");
    }
    
    // Helper classes
    private static class TestCase {
        final String currency;
        final boolean expectedValid;
        final String description;
        
        TestCase(String currency, boolean expectedValid, String description) {
            this.currency = currency;
            this.expectedValid = expectedValid;
            this.description = description;
        }
    }
    
    private static class BoundaryTest {
        final BigDecimal amount;
        final String paymentMode;
        final boolean expectedValid;
        final String description;
        
        BoundaryTest(BigDecimal amount, String paymentMode, boolean expectedValid, String description) {
            this.amount = amount;
            this.paymentMode = paymentMode;
            this.expectedValid = expectedValid;
            this.description = description;
        }
    }
}
```

## 🧪 Integration Test Examples

### Database Integration Tests

```java
// Prompt: "Create integration tests for payment validation with database"
// Context: Test database constraints and transaction integrity

@SpringBootTest
@Transactional
@Sql(scripts = "/test-data/payment-validation-setup.sql")
class PaymentValidationIntegrationTest {
    
    @Autowired
    private PaymentValidationService validationService;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    @DisplayName("Should validate account existence in database")
    void shouldValidateAccountExistenceInDatabase() {
        // Given - Account exists in test database
        String existingAccount = "1234567890123456";
        String nonExistentAccount = "9999999999999999";
        
        PaymentRequest validRequest = PaymentRequest.builder()
            .fromAccount(existingAccount)
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.00"))
            .currency("INR")
            .build();
            
        PaymentRequest invalidRequest = PaymentRequest.builder()
            .fromAccount(nonExistentAccount)
            .toAccount("9876543210987654")
            .amount(new BigDecimal("1000.00"))
            .currency("INR")
            .build();
        
        // When
        ValidationResult validResult = validationService.validatePayment(validRequest);
        ValidationResult invalidResult = validationService.validatePayment(invalidRequest);
        
        // Then
        assertThat(validResult.isValid()).isTrue();
        assertThat(invalidResult.isValid()).isFalse();
        assertThat(invalidResult.getErrors()).contains("Account not found");
    }
    
    @Test
    @DisplayName("Should check account balance constraints")
    void shouldCheckAccountBalanceConstraints() {
        // Given - Account with specific balance
        String accountNumber = "1234567890123456";
        BigDecimal availableBalance = new BigDecimal("10000.00");
        
        // Update account balance in test database
        entityManager.getEntityManager()
            .createNativeQuery("UPDATE accounts SET balance = :balance WHERE account_number = :account")
            .setParameter("balance", availableBalance)
            .setParameter("account", accountNumber)
            .executeUpdate();
        
        PaymentRequest sufficientFunds = PaymentRequest.builder()
            .fromAccount(accountNumber)
            .toAccount("9876543210987654")
            .amount(new BigDecimal("5000.00"))
            .currency("INR")
            .build();
            
        PaymentRequest insufficientFunds = PaymentRequest.builder()
            .fromAccount(accountNumber)
            .toAccount("9876543210987654")
            .amount(new BigDecimal("15000.00"))
            .currency("INR")
            .build();
        
        // When
        ValidationResult sufficientResult = validationService.validatePayment(sufficientFunds);
        ValidationResult insufficientResult = validationService.validatePayment(insufficientFunds);
        
        // Then
        assertThat(sufficientResult.isValid()).isTrue();
        assertThat(insufficientResult.isValid()).isFalse();
        assertThat(insufficientResult.getErrors()).contains("Insufficient balance");
    }
}
```

## 🎯 Test Data Generation

### Dynamic Test Data Creation

```java
// Prompt: "Create utility for generating realistic test payment data"
// Context: Generate test data that matches real-world payment patterns

@Component
public class PaymentTestDataGenerator {
    
    private static final List<String> VALID_ACCOUNT_NUMBERS = Arrays.asList(
        "1234567890123456", "2345678901234567", "3456789012345678",
        "4567890123456789", "5678901234567890"
    );
    
    private static final List<String> PAYMENT_PURPOSES = Arrays.asList(
        "SALARY", "BUSINESS_PAYMENT", "UTILITY_BILL", "LOAN_REPAYMENT",
        "INVESTMENT", "INSURANCE_PREMIUM", "FAMILY_SUPPORT"
    );
    
    private final Random random = new Random();
    
    public PaymentRequest generateValidPaymentRequest() {
        return PaymentRequest.builder()
            .fromAccount(getRandomAccount())
            .toAccount(getRandomAccount())
            .amount(generateRandomAmount(1.00, 100000.00))
            .currency("INR")
            .purpose(getRandomPurpose())
            .paymentMode(getRandomPaymentMode())
            .scheduledTime(generateRandomFutureTime())
            .build();
    }
    
    public List<PaymentRequest> generateBulkPaymentRequests(int count) {
        return IntStream.range(0, count)
            .mapToObj(i -> generateValidPaymentRequest())
            .collect(Collectors.toList());
    }
    
    public PaymentRequest generateFraudulentPaymentRequest() {
        return PaymentRequest.builder()
            .fromAccount(getRandomAccount())
            .toAccount("1111111111111111") // Known fraudulent account
            .amount(generateRandomAmount(50000.00, 200000.00)) // High amount
            .currency("INR")
            .purpose("UNKNOWN")
            .timestamp(LocalDateTime.now().minusMinutes(1)) // Very recent
            .build();
    }
    
    private BigDecimal generateRandomAmount(double min, double max) {
        double amount = min + (max - min) * random.nextDouble();
        return new BigDecimal(amount).setScale(2, RoundingMode.HALF_UP);
    }
    
    private String getRandomAccount() {
        return VALID_ACCOUNT_NUMBERS.get(random.nextInt(VALID_ACCOUNT_NUMBERS.size()));
    }
    
    private String getRandomPurpose() {
        return PAYMENT_PURPOSES.get(random.nextInt(PAYMENT_PURPOSES.size()));
    }
    
    private String getRandomPaymentMode() {
        String[] modes = {"NEFT", "IMPS", "UPI", "RTGS"};
        return modes[random.nextInt(modes.length)];
    }
    
    private LocalDateTime generateRandomFutureTime() {
        return LocalDateTime.now().plusMinutes(random.nextInt(1440)); // Within 24 hours
    }
}
```

## 📊 Test Reporting and Analytics

```java
// Prompt: "Create comprehensive test reporting for payment validation"
// Context: Generate detailed test reports for compliance audits

@Component
public class PaymentValidationTestReporter {
    
    public TestExecutionReport generateTestReport(List<TestResult> results) {
        TestExecutionReport report = new TestExecutionReport();
        
        // Summary statistics
        report.setTotalTests(results.size());
        report.setPassedTests(results.stream().mapToInt(r -> r.isPassed() ? 1 : 0).sum());
        report.setFailedTests(results.size() - report.getPassedTests());
        report.setSuccessRate((double) report.getPassedTests() / report.getTotalTests() * 100);
        
        // Category breakdown
        report.setCategoryBreakdown(results.stream()
            .collect(Collectors.groupingBy(
                TestResult::getCategory,
                Collectors.summingInt(r -> r.isPassed() ? 1 : 0)
            )));
        
        // Performance metrics
        report.setAverageExecutionTime(results.stream()
            .mapToLong(TestResult::getExecutionTime)
            .average()
            .orElse(0.0));
        
        // Compliance coverage
        report.setComplianceCoverage(calculateComplianceCoverage(results));
        
        return report;
    }
    
    private Map<String, Double> calculateComplianceCoverage(List<TestResult> results) {
        Map<String, Double> coverage = new HashMap<>();
        
        coverage.put("RBI_COMPLIANCE", calculateCoverageForRegulator(results, "RBI"));
        coverage.put("NPCI_COMPLIANCE", calculateCoverageForRegulator(results, "NPCI"));
        coverage.put("SECURITY_COMPLIANCE", calculateCoverageForRegulator(results, "SECURITY"));
        
        return coverage;
    }
    
    private Double calculateCoverageForRegulator(List<TestResult> results, String regulator) {
        List<TestResult> regulatorTests = results.stream()
            .filter(r -> r.getComplianceAreas().contains(regulator))
            .collect(Collectors.toList());
            
        if (regulatorTests.isEmpty()) return 0.0;
        
        return (double) regulatorTests.stream()
            .mapToInt(r -> r.isPassed() ? 1 : 0)
            .sum() / regulatorTests.size() * 100;
    }
}
```

---

**Next Steps**: Proceed to [BFSI Code Templates](../templates/README.md) to explore reusable code patterns for common financial operations.