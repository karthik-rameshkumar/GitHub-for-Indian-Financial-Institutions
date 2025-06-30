# Payment Validation Service Template

This template provides a comprehensive payment validation service designed for BFSI applications with GitHub Copilot integration. It includes RBI compliance, fraud detection, and audit logging.

## 🎯 Copilot Prompt Template

```markdown
**Context**: Create a comprehensive payment validation service for Indian banking
**Domain**: Digital payment processing (UPI, IMPS, NEFT, RTGS)
**Compliance**: RBI guidelines for digital payments, NPCI standards
**Security**: PCI DSS Level 1, fraud detection integration
**Performance**: Handle 10,000+ transactions per second
**Audit**: Complete transaction audit trail for regulatory compliance
```

## 🏗️ Implementation Template

```java
/**
 * Payment Validation Service Template for BFSI Applications
 * 
 * Compliance: RBI IT Framework, NPCI Standards
 * Security: PCI DSS Level 1, Fraud Detection
 * Performance: High-throughput transaction processing
 * Audit: Complete transaction logging
 * 
 * Usage with GitHub Copilot:
 * 1. Copy this template
 * 2. Customize business rules
 * 3. Use Copilot to generate additional validation methods
 * 4. Add institution-specific compliance checks
 */

@Service
@Slf4j
@Validated
public class PaymentValidationService {
    
    // Dependencies for comprehensive validation
    private final AccountService accountService;
    private final FraudDetectionService fraudDetectionService;
    private final RegulatoryComplianceService complianceService;
    private final AuditService auditService;
    private final CacheManager cacheManager;
    
    // Configuration properties for different payment modes
    @Value("${payment.limits.upi.daily:100000}")
    private BigDecimal upiDailyLimit;
    
    @Value("${payment.limits.imps.per.transaction:200000}")
    private BigDecimal impsTransactionLimit;
    
    @Value("${payment.limits.neft.daily:1000000}")
    private BigDecimal neftDailyLimit;
    
    @Value("${payment.limits.rtgs.minimum:200000}")
    private BigDecimal rtgsMinimumAmount;
    
    // Business hours configuration
    @Value("${payment.business.hours.start:09:00}")
    private LocalTime businessHoursStart;
    
    @Value("${payment.business.hours.end:18:00}")
    private LocalTime businessHoursEnd;
    
    public PaymentValidationService(
            AccountService accountService,
            FraudDetectionService fraudDetectionService,
            RegulatoryComplianceService complianceService,
            AuditService auditService,
            CacheManager cacheManager) {
        this.accountService = accountService;
        this.fraudDetectionService = fraudDetectionService;
        this.complianceService = complianceService;
        this.auditService = auditService;
        this.cacheManager = cacheManager;
    }
    
    /**
     * Main payment validation method
     * GitHub Copilot will help generate comprehensive validation logic
     */
    @Transactional(readOnly = true)
    @Timed(name = "payment.validation.duration")
    public ValidationResult validatePayment(@Valid PaymentRequest request) {
        
        // Create audit context for tracking
        AuditContext auditContext = AuditContext.builder()
            .transactionId(request.getTransactionId())
            .userId(request.getUserId())
            .timestamp(Instant.now())
            .operation("PAYMENT_VALIDATION")
            .build();
        
        try {
            log.info("Starting payment validation for transaction: {}", request.getTransactionId());
            
            // Step 1: Basic input validation
            ValidationResult basicValidation = validateBasicInputs(request);
            if (!basicValidation.isValid()) {
                auditService.logValidationFailure(auditContext, basicValidation);
                return basicValidation;
            }
            
            // Step 2: Account validation
            ValidationResult accountValidation = validateAccounts(request);
            if (!accountValidation.isValid()) {
                auditService.logValidationFailure(auditContext, accountValidation);
                return accountValidation;
            }
            
            // Step 3: Amount and limit validation
            ValidationResult amountValidation = validateAmountAndLimits(request);
            if (!amountValidation.isValid()) {
                auditService.logValidationFailure(auditContext, amountValidation);
                return amountValidation;
            }
            
            // Step 4: Payment mode specific validation
            ValidationResult modeValidation = validatePaymentMode(request);
            if (!modeValidation.isValid()) {
                auditService.logValidationFailure(auditContext, modeValidation);
                return modeValidation;
            }
            
            // Step 5: Regulatory compliance validation
            ValidationResult complianceValidation = validateCompliance(request);
            if (!complianceValidation.isValid()) {
                auditService.logValidationFailure(auditContext, complianceValidation);
                return complianceValidation;
            }
            
            // Step 6: Fraud detection
            ValidationResult fraudValidation = validateFraudRisk(request);
            if (!fraudValidation.isValid()) {
                auditService.logValidationFailure(auditContext, fraudValidation);
                return fraudValidation;
            }
            
            // Step 7: Business rules validation
            ValidationResult businessValidation = validateBusinessRules(request);
            if (!businessValidation.isValid()) {
                auditService.logValidationFailure(auditContext, businessValidation);
                return businessValidation;
            }
            
            // All validations passed
            ValidationResult successResult = ValidationResult.success()
                .withTransactionId(request.getTransactionId())
                .withValidationTimestamp(Instant.now())
                .withAppliedRules(getAllAppliedRules(request));
            
            auditService.logValidationSuccess(auditContext, successResult);
            log.info("Payment validation successful for transaction: {}", request.getTransactionId());
            
            return successResult;
            
        } catch (Exception e) {
            log.error("Payment validation failed with exception for transaction: {}", 
                     request.getTransactionId(), e);
            
            ValidationResult errorResult = ValidationResult.error()
                .withError("VALIDATION_SYSTEM_ERROR", "System error during validation")
                .withTransactionId(request.getTransactionId());
            
            auditService.logValidationError(auditContext, errorResult, e);
            return errorResult;
        }
    }
    
    /**
     * Basic input validation - GitHub Copilot will help generate comprehensive checks
     */
    private ValidationResult validateBasicInputs(PaymentRequest request) {
        List<ValidationError> errors = new ArrayList<>();
        
        // Null and empty checks
        if (request == null) {
            errors.add(new ValidationError("NULL_REQUEST", "Payment request cannot be null"));
            return ValidationResult.failure(errors);
        }
        
        if (StringUtils.isBlank(request.getFromAccount())) {
            errors.add(new ValidationError("EMPTY_FROM_ACCOUNT", "From account number cannot be empty"));
        }
        
        if (StringUtils.isBlank(request.getToAccount())) {
            errors.add(new ValidationError("EMPTY_TO_ACCOUNT", "To account number cannot be empty"));
        }
        
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add(new ValidationError("INVALID_AMOUNT", "Amount must be greater than zero"));
        }
        
        if (StringUtils.isBlank(request.getCurrency())) {
            errors.add(new ValidationError("EMPTY_CURRENCY", "Currency cannot be empty"));
        } else if (!"INR".equals(request.getCurrency())) {
            errors.add(new ValidationError("INVALID_CURRENCY", "Only INR currency is supported"));
        }
        
        // Account number format validation
        if (!isValidAccountNumberFormat(request.getFromAccount())) {
            errors.add(new ValidationError("INVALID_FROM_ACCOUNT_FORMAT", 
                                         "From account number format is invalid"));
        }
        
        if (!isValidAccountNumberFormat(request.getToAccount())) {
            errors.add(new ValidationError("INVALID_TO_ACCOUNT_FORMAT", 
                                         "To account number format is invalid"));
        }
        
        // Amount precision validation (max 2 decimal places for INR)
        if (request.getAmount() != null && request.getAmount().scale() > 2) {
            errors.add(new ValidationError("INVALID_AMOUNT_PRECISION", 
                                         "Amount cannot have more than 2 decimal places"));
        }
        
        return errors.isEmpty() ? ValidationResult.success() : ValidationResult.failure(errors);
    }
    
    /**
     * Account validation - GitHub Copilot will help generate account-specific checks
     */
    @Cacheable(value = "accountValidation", key = "#request.fromAccount + '_' + #request.toAccount")
    private ValidationResult validateAccounts(PaymentRequest request) {
        List<ValidationError> errors = new ArrayList<>();
        List<ValidationWarning> warnings = new ArrayList<>();
        
        // Check if from account exists and is active
        AccountStatus fromAccountStatus = accountService.getAccountStatus(request.getFromAccount());
        if (fromAccountStatus == AccountStatus.NOT_FOUND) {
            errors.add(new ValidationError("FROM_ACCOUNT_NOT_FOUND", "From account does not exist"));
        } else if (fromAccountStatus != AccountStatus.ACTIVE) {
            errors.add(new ValidationError("FROM_ACCOUNT_INACTIVE", 
                                         "From account is not active: " + fromAccountStatus));
        }
        
        // Check if to account exists and can receive payments
        AccountStatus toAccountStatus = accountService.getAccountStatus(request.getToAccount());
        if (toAccountStatus == AccountStatus.NOT_FOUND) {
            errors.add(new ValidationError("TO_ACCOUNT_NOT_FOUND", "To account does not exist"));
        } else if (toAccountStatus == AccountStatus.FROZEN) {
            errors.add(new ValidationError("TO_ACCOUNT_FROZEN", "To account is frozen"));
        }
        
        // Check if accounts are same
        if (request.getFromAccount().equals(request.getToAccount())) {
            errors.add(new ValidationError("SAME_ACCOUNT", "From and to accounts cannot be the same"));
        }
        
        // Check account balance
        if (errors.isEmpty()) {
            BigDecimal availableBalance = accountService.getAvailableBalance(request.getFromAccount());
            if (availableBalance.compareTo(request.getAmount()) < 0) {
                errors.add(new ValidationError("INSUFFICIENT_BALANCE", "Insufficient account balance"));
            }
            
            // Warning for low balance after transaction
            BigDecimal remainingBalance = availableBalance.subtract(request.getAmount());
            BigDecimal minimumBalance = accountService.getMinimumBalance(request.getFromAccount());
            if (remainingBalance.compareTo(minimumBalance) < 0) {
                warnings.add(new ValidationWarning("LOW_BALANCE_WARNING", 
                                                 "Account balance will be below minimum after transaction"));
            }
        }
        
        return errors.isEmpty() ? 
            ValidationResult.success().withWarnings(warnings) : 
            ValidationResult.failure(errors);
    }
    
    /**
     * Amount and limit validation - GitHub Copilot will help generate limit checks
     */
    private ValidationResult validateAmountAndLimits(PaymentRequest request) {
        List<ValidationError> errors = new ArrayList<>();
        List<ValidationWarning> warnings = new ArrayList<>();
        
        String paymentMode = request.getPaymentMode();
        BigDecimal amount = request.getAmount();
        
        // Per-transaction limits based on payment mode
        switch (paymentMode.toUpperCase()) {
            case "UPI":
                if (amount.compareTo(new BigDecimal("100000")) > 0) {
                    errors.add(new ValidationError("UPI_LIMIT_EXCEEDED", 
                                                 "UPI transaction limit of ₹1,00,000 exceeded"));
                }
                break;
                
            case "IMPS":
                if (amount.compareTo(impsTransactionLimit) > 0) {
                    errors.add(new ValidationError("IMPS_LIMIT_EXCEEDED", 
                                                 "IMPS transaction limit exceeded"));
                }
                break;
                
            case "RTGS":
                if (amount.compareTo(rtgsMinimumAmount) < 0) {
                    errors.add(new ValidationError("RTGS_MINIMUM_NOT_MET", 
                                                 "RTGS minimum amount of ₹2,00,000 not met"));
                }
                break;
        }
        
        // Daily limit validation
        BigDecimal dailyTransactionAmount = accountService.getDailyTransactionAmount(
            request.getFromAccount(), LocalDate.now());
        BigDecimal totalDailyAmount = dailyTransactionAmount.add(amount);
        
        BigDecimal dailyLimit = getDailyLimitForPaymentMode(paymentMode);
        if (totalDailyAmount.compareTo(dailyLimit) > 0) {
            errors.add(new ValidationError("DAILY_LIMIT_EXCEEDED", 
                                         "Daily transaction limit exceeded"));
        }
        
        // Monthly limit validation
        BigDecimal monthlyTransactionAmount = accountService.getMonthlyTransactionAmount(
            request.getFromAccount(), YearMonth.now());
        BigDecimal monthlyLimit = getMonthlyLimitForAccount(request.getFromAccount());
        
        if (monthlyTransactionAmount.add(amount).compareTo(monthlyLimit) > 0) {
            warnings.add(new ValidationWarning("APPROACHING_MONTHLY_LIMIT", 
                                             "Approaching monthly transaction limit"));
        }
        
        return errors.isEmpty() ? 
            ValidationResult.success().withWarnings(warnings) : 
            ValidationResult.failure(errors);
    }
    
    /**
     * Payment mode specific validation - GitHub Copilot will help generate mode-specific rules
     */
    private ValidationResult validatePaymentMode(PaymentRequest request) {
        List<ValidationError> errors = new ArrayList<>();
        List<ValidationWarning> warnings = new ArrayList<>();
        
        String paymentMode = request.getPaymentMode().toUpperCase();
        LocalDateTime scheduledTime = request.getScheduledTime();
        
        switch (paymentMode) {
            case "NEFT":
                ValidationResult neftValidation = validateNEFTSpecificRules(request, scheduledTime);
                errors.addAll(neftValidation.getErrors());
                warnings.addAll(neftValidation.getWarnings());
                break;
                
            case "RTGS":
                ValidationResult rtgsValidation = validateRTGSSpecificRules(request, scheduledTime);
                errors.addAll(rtgsValidation.getErrors());
                warnings.addAll(rtgsValidation.getWarnings());
                break;
                
            case "IMPS":
                ValidationResult impsValidation = validateIMPSSpecificRules(request);
                errors.addAll(impsValidation.getErrors());
                warnings.addAll(impsValidation.getWarnings());
                break;
                
            case "UPI":
                ValidationResult upiValidation = validateUPISpecificRules(request);
                errors.addAll(upiValidation.getErrors());
                warnings.addAll(upiValidation.getWarnings());
                break;
                
            default:
                errors.add(new ValidationError("INVALID_PAYMENT_MODE", 
                                             "Invalid payment mode: " + paymentMode));
        }
        
        return errors.isEmpty() ? 
            ValidationResult.success().withWarnings(warnings) : 
            ValidationResult.failure(errors);
    }
    
    /**
     * Regulatory compliance validation - GitHub Copilot will help generate compliance checks
     */
    private ValidationResult validateCompliance(PaymentRequest request) {
        // Use compliance service to check RBI, NPCI, and other regulatory requirements
        ComplianceCheckResult complianceResult = complianceService.checkCompliance(request);
        
        if (!complianceResult.isCompliant()) {
            List<ValidationError> errors = complianceResult.getViolations().stream()
                .map(violation -> new ValidationError("COMPLIANCE_VIOLATION", violation))
                .collect(Collectors.toList());
            return ValidationResult.failure(errors);
        }
        
        return ValidationResult.success()
            .withComplianceScore(complianceResult.getComplianceScore())
            .withAppliedRegulations(complianceResult.getAppliedRegulations());
    }
    
    /**
     * Fraud risk validation - GitHub Copilot will help generate fraud detection logic
     */
    private ValidationResult validateFraudRisk(PaymentRequest request) {
        FraudAssessmentResult fraudResult = fraudDetectionService.assessFraudRisk(request);
        
        if (fraudResult.getRiskLevel() == RiskLevel.HIGH) {
            return ValidationResult.failure(
                Arrays.asList(new ValidationError("HIGH_FRAUD_RISK", 
                                                "Transaction flagged as high fraud risk"))
            ).withFraudScore(fraudResult.getFraudScore());
        }
        
        if (fraudResult.getRiskLevel() == RiskLevel.MEDIUM) {
            return ValidationResult.success()
                .withWarnings(Arrays.asList(
                    new ValidationWarning("MEDIUM_FRAUD_RISK", 
                                         "Transaction flagged for additional review")
                ))
                .withFraudScore(fraudResult.getFraudScore());
        }
        
        return ValidationResult.success().withFraudScore(fraudResult.getFraudScore());
    }
    
    /**
     * Business rules validation - GitHub Copilot will help generate custom business logic
     */
    private ValidationResult validateBusinessRules(PaymentRequest request) {
        List<ValidationError> errors = new ArrayList<>();
        List<ValidationWarning> warnings = new ArrayList<>();
        
        // Example business rules - customize based on institution requirements
        
        // Rule 1: High-value transaction additional verification
        if (request.getAmount().compareTo(new BigDecimal("100000")) > 0) {
            if (StringUtils.isBlank(request.getPurpose())) {
                errors.add(new ValidationError("PURPOSE_REQUIRED", 
                                             "Purpose is required for high-value transactions"));
            }
        }
        
        // Rule 2: Weekend/holiday processing
        if (isWeekendOrHoliday(request.getScheduledTime())) {
            warnings.add(new ValidationWarning("WEEKEND_PROCESSING", 
                                             "Transaction scheduled for next working day"));
        }
        
        // Rule 3: Customer category specific limits
        CustomerCategory category = accountService.getCustomerCategory(request.getFromAccount());
        if (category == CustomerCategory.BASIC && 
            request.getAmount().compareTo(new BigDecimal("25000")) > 0) {
            errors.add(new ValidationError("CATEGORY_LIMIT_EXCEEDED", 
                                         "Transaction amount exceeds limit for basic account"));
        }
        
        return errors.isEmpty() ? 
            ValidationResult.success().withWarnings(warnings) : 
            ValidationResult.failure(errors);
    }
    
    // Helper methods - GitHub Copilot will help generate utility functions
    
    private boolean isValidAccountNumberFormat(String accountNumber) {
        if (StringUtils.isBlank(accountNumber)) {
            return false;
        }
        
        // Account number should be 10-20 digits
        return accountNumber.matches("\\d{10,20}");
    }
    
    private BigDecimal getDailyLimitForPaymentMode(String paymentMode) {
        return switch (paymentMode.toUpperCase()) {
            case "UPI" -> new BigDecimal("100000");
            case "IMPS" -> new BigDecimal("200000");
            case "NEFT" -> neftDailyLimit;
            case "RTGS" -> new BigDecimal("10000000"); // 1 crore
            default -> new BigDecimal("50000");
        };
    }
    
    private BigDecimal getMonthlyLimitForAccount(String accountNumber) {
        CustomerCategory category = accountService.getCustomerCategory(accountNumber);
        return switch (category) {
            case PREMIUM -> new BigDecimal("10000000");
            case STANDARD -> new BigDecimal("5000000");
            case BASIC -> new BigDecimal("1000000");
            default -> new BigDecimal("500000");
        };
    }
    
    private boolean isWeekendOrHoliday(LocalDateTime dateTime) {
        DayOfWeek dayOfWeek = dateTime.getDayOfWeek();
        return dayOfWeek == DayOfWeek.SATURDAY || 
               dayOfWeek == DayOfWeek.SUNDAY ||
               holidayService.isHoliday(dateTime.toLocalDate());
    }
    
    private ValidationResult validateNEFTSpecificRules(PaymentRequest request, LocalDateTime scheduledTime) {
        // NEFT specific validation logic
        // GitHub Copilot will help generate comprehensive NEFT rules
        return ValidationResult.success();
    }
    
    private ValidationResult validateRTGSSpecificRules(PaymentRequest request, LocalDateTime scheduledTime) {
        // RTGS specific validation logic
        // GitHub Copilot will help generate comprehensive RTGS rules
        return ValidationResult.success();
    }
    
    private ValidationResult validateIMPSSpecificRules(PaymentRequest request) {
        // IMPS specific validation logic
        // GitHub Copilot will help generate comprehensive IMPS rules
        return ValidationResult.success();
    }
    
    private ValidationResult validateUPISpecificRules(PaymentRequest request) {
        // UPI specific validation logic
        // GitHub Copilot will help generate comprehensive UPI rules
        return ValidationResult.success();
    }
    
    private List<String> getAllAppliedRules(PaymentRequest request) {
        // Return list of all validation rules that were applied
        return Arrays.asList(
            "BASIC_INPUT_VALIDATION",
            "ACCOUNT_VALIDATION",
            "AMOUNT_LIMIT_VALIDATION",
            "PAYMENT_MODE_VALIDATION",
            "COMPLIANCE_VALIDATION",
            "FRAUD_RISK_VALIDATION",
            "BUSINESS_RULES_VALIDATION"
        );
    }
}

/**
 * Supporting classes for payment validation
 * GitHub Copilot will help generate comprehensive data models
 */

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {
    
    @NotBlank(message = "Transaction ID is required")
    private String transactionId;
    
    @NotBlank(message = "From account is required")
    @Size(min = 10, max = 20, message = "Account number must be 10-20 digits")
    @Pattern(regexp = "\\d+", message = "Account number must contain only digits")
    private String fromAccount;
    
    @NotBlank(message = "To account is required")
    @Size(min = 10, max = 20, message = "Account number must be 10-20 digits")
    @Pattern(regexp = "\\d+", message = "Account number must contain only digits")
    private String toAccount;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    @Digits(integer = 10, fraction = 2, message = "Invalid amount format")
    private BigDecimal amount;
    
    @NotBlank(message = "Currency is required")
    @Pattern(regexp = "INR", message = "Only INR currency is supported")
    private String currency;
    
    @NotBlank(message = "Payment mode is required")
    @Pattern(regexp = "UPI|IMPS|NEFT|RTGS", message = "Invalid payment mode")
    private String paymentMode;
    
    private String purpose;
    private String userId;
    private LocalDateTime timestamp;
    private LocalDateTime scheduledTime;
    private Map<String, Object> metadata;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ValidationResult {
    
    private boolean valid;
    private String transactionId;
    private Instant validationTimestamp;
    private List<ValidationError> errors = new ArrayList<>();
    private List<ValidationWarning> warnings = new ArrayList<>();
    private Double fraudScore;
    private Integer complianceScore;
    private List<String> appliedRules = new ArrayList<>();
    private List<String> appliedRegulations = new ArrayList<>();
    
    public static ValidationResult success() {
        return ValidationResult.builder().valid(true).build();
    }
    
    public static ValidationResult failure(List<ValidationError> errors) {
        return ValidationResult.builder().valid(false).errors(errors).build();
    }
    
    public static ValidationResult error() {
        return ValidationResult.builder().valid(false).build();
    }
    
    public ValidationResult withWarnings(List<ValidationWarning> warnings) {
        this.warnings = warnings;
        return this;
    }
    
    public ValidationResult withFraudScore(Double fraudScore) {
        this.fraudScore = fraudScore;
        return this;
    }
    
    public ValidationResult withComplianceScore(Integer complianceScore) {
        this.complianceScore = complianceScore;
        return this;
    }
    
    public ValidationResult withTransactionId(String transactionId) {
        this.transactionId = transactionId;
        return this;
    }
    
    public ValidationResult withValidationTimestamp(Instant timestamp) {
        this.validationTimestamp = timestamp;
        return this;
    }
    
    public ValidationResult withAppliedRules(List<String> appliedRules) {
        this.appliedRules = appliedRules;
        return this;
    }
    
    public ValidationResult withAppliedRegulations(List<String> appliedRegulations) {
        this.appliedRegulations = appliedRegulations;
        return this;
    }
    
    public ValidationResult withError(String code, String message) {
        this.errors.add(new ValidationError(code, message));
        return this;
    }
}

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ValidationError {
    private String errorCode;
    private String errorMessage;
    private Instant timestamp = Instant.now();
}

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ValidationWarning {
    private String warningCode;
    private String warningMessage;
    private Instant timestamp = Instant.now();
}

// Enums for validation
enum AccountStatus {
    ACTIVE, INACTIVE, FROZEN, CLOSED, NOT_FOUND
}

enum CustomerCategory {
    BASIC, STANDARD, PREMIUM
}

enum RiskLevel {
    LOW, MEDIUM, HIGH
}
```

## 🧪 Usage Examples

### Basic Usage with GitHub Copilot

```java
// Prompt: "Create payment validation for UPI transaction"
@RestController
@RequestMapping("/api/payments")
public class PaymentController {
    
    @Autowired
    private PaymentValidationService validationService;
    
    @PostMapping("/validate")
    public ResponseEntity<ValidationResult> validatePayment(@RequestBody PaymentRequest request) {
        ValidationResult result = validationService.validatePayment(request);
        
        if (result.isValid()) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }
}
```

### Advanced Usage with Custom Rules

```java
// Prompt: "Extend payment validation with custom business rules for premium customers"
@Component
public class PremiumCustomerValidationExtension {
    
    public ValidationResult validatePremiumCustomerRules(PaymentRequest request) {
        // GitHub Copilot will help generate premium customer specific logic
        CustomerProfile profile = customerService.getProfile(request.getFromAccount());
        
        if (profile.getCategory() == CustomerCategory.PREMIUM) {
            // Premium customers get higher limits and different rules
            // Copilot will suggest appropriate validation logic
        }
        
        return ValidationResult.success();
    }
}
```

## 🔧 Customization Points

### Institution-Specific Rules

```java
// Prompt: "Add institution-specific validation rules"
@Value("${bank.name}")
private String bankName;

private ValidationResult validateInstitutionSpecificRules(PaymentRequest request) {
    // GitHub Copilot will help generate bank-specific validation logic
    return switch (bankName) {
        case "STATE_BANK" -> validateStateBankRules(request);
        case "PRIVATE_BANK" -> validatePrivateBankRules(request);
        case "COOPERATIVE_BANK" -> validateCooperativeBankRules(request);
        default -> ValidationResult.success();
    };
}
```

### Performance Optimization

```java
// Prompt: "Optimize payment validation for high throughput"
@Async("paymentValidationExecutor")
@Cacheable(value = "validationCache", key = "#request.cacheKey()")
public CompletableFuture<ValidationResult> validatePaymentAsync(PaymentRequest request) {
    // GitHub Copilot will help generate optimized async validation
    return CompletableFuture.completedFuture(validatePayment(request));
}
```

## 📊 Monitoring and Metrics

```java
// Prompt: "Add comprehensive monitoring for payment validation"
@Component
public class PaymentValidationMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Counter validationCounter;
    private final Timer validationTimer;
    
    public PaymentValidationMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.validationCounter = Counter.builder("payment.validation.total")
            .description("Total payment validations")
            .register(meterRegistry);
        this.validationTimer = Timer.builder("payment.validation.duration")
            .description("Payment validation duration")
            .register(meterRegistry);
    }
    
    public void recordValidation(ValidationResult result) {
        validationCounter.increment(
            Tags.of(
                "status", result.isValid() ? "success" : "failure",
                "payment_mode", extractPaymentMode(result)
            )
        );
    }
}
```

---

**Next Steps**: 
- Use this template with GitHub Copilot to generate your payment validation service
- Customize the business rules for your specific institution
- Add additional validation methods using Copilot assistance
- Review [Fraud Detection Templates](../fraud-detection/fraud-scoring-engine.md) for integration