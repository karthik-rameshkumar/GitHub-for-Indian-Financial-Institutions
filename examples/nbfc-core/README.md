# NBFC Core System Example

A complete example of a Non-Banking Financial Company (NBFC) core system implementation with secure CI/CD pipeline, demonstrating best practices for financial institutions in India.

## Overview

This example application demonstrates:
- **Loan Origination System**: End-to-end loan processing
- **Customer Management**: KYC-compliant customer onboarding
- **Risk Assessment**: Credit scoring and risk evaluation
- **Regulatory Compliance**: RBI NBFC guidelines implementation
- **Secure Architecture**: Data protection and encryption
- **Audit Trail**: Complete transaction logging

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Portal    │    │   Core Services  │    │   Data Layer    │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ • Customer UI   │───▶│ • Loan Service   │───▶│ • PostgreSQL    │
│ • Admin Portal  │    │ • Customer Svc   │    │ • Redis Cache   │
│ • Mobile App    │    │ • Risk Engine    │    │ • Document Store│
└─────────────────┘    │ • Payment Svc    │    └─────────────────┘
                       │ • Audit Service  │
                       └──────────────────┘
```

## Technology Stack

- **Backend**: Java 17, Spring Boot 3.1
- **Database**: PostgreSQL 14 with encryption at rest
- **Cache**: Redis 7.0 with authentication
- **Message Queue**: Apache Kafka for event streaming
- **Security**: Spring Security with JWT tokens
- **Documentation**: OpenAPI 3.0 with Swagger UI
- **Monitoring**: Micrometer with Prometheus metrics

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.8+
- Docker & Docker Compose
- PostgreSQL 14+

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/nbfc-core.git
cd nbfc-core

# Start infrastructure services
docker-compose up -d postgres redis kafka

# Build and run the application
mvn clean install
mvn spring-boot:run

# Access the application
open http://localhost:8080
```

## Project Structure

```
nbfc-core/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/financial/nbfc/
│   │   │       ├── customer/         # Customer management
│   │   │       ├── loan/             # Loan processing
│   │   │       ├── risk/             # Risk assessment
│   │   │       ├── payment/          # Payment processing
│   │   │       ├── audit/            # Audit trail
│   │   │       └── security/         # Security config
│   │   └── resources/
│   │       ├── application.yml       # Configuration
│   │       ├── db/migration/         # Database schemas
│   │       └── static/               # Web assets
│   └── test/                         # Unit and integration tests
├── docker-compose.yml               # Local development setup
├── Dockerfile                       # Container image
├── pom.xml                          # Maven configuration
└── README.md                        # This file
```

## Core Features

### 1. Customer Management

```java
@RestController
@RequestMapping("/api/customers")
@Validated
public class CustomerController {
    
    @PostMapping
    @Operation(summary = "Create new customer with KYC")
    public ResponseEntity<Customer> createCustomer(
            @Valid @RequestBody CreateCustomerRequest request) {
        
        // Validate KYC documents
        kycService.validateDocuments(request.getKycDocuments());
        
        // Create customer
        Customer customer = customerService.createCustomer(request);
        
        // Log audit event
        auditService.logEvent("CUSTOMER_CREATED", customer.getId());
        
        return ResponseEntity.ok(customer);
    }
}
```

### 2. Loan Processing

```java
@Service
@Transactional
public class LoanService {
    
    public LoanApplication processLoanApplication(CreateLoanRequest request) {
        // Risk assessment
        RiskScore riskScore = riskEngine.calculateRisk(request);
        
        if (riskScore.getScore() < MINIMUM_SCORE) {
            throw new LoanRejectedException("Insufficient credit score");
        }
        
        // Create loan application
        LoanApplication application = new LoanApplication();
        application.setCustomerId(request.getCustomerId());
        application.setAmount(request.getAmount());
        application.setRiskScore(riskScore);
        application.setStatus(LoanStatus.UNDER_REVIEW);
        
        // Save and publish event
        LoanApplication saved = loanRepository.save(application);
        eventPublisher.publishEvent(new LoanApplicationCreated(saved.getId()));
        
        return saved;
    }
}
```

### 3. Risk Assessment

```java
@Component
public class RiskEngine {
    
    public RiskScore calculateRisk(CreateLoanRequest request) {
        // Credit bureau integration
        CreditReport creditReport = creditBureauService.getCreditReport(
            request.getCustomerId()
        );
        
        // Calculate risk factors
        double creditScore = creditReport.getScore();
        double incomeRatio = request.getAmount() / request.getMonthlyIncome();
        double existingDebtRatio = creditReport.getTotalDebt() / request.getMonthlyIncome();
        
        // Risk scoring algorithm
        double riskScore = (creditScore * 0.4) + 
                          ((1 - incomeRatio) * 0.3) + 
                          ((1 - existingDebtRatio) * 0.3);
        
        return new RiskScore(riskScore, getRiskCategory(riskScore));
    }
}
```

## Security Implementation

### 1. Data Encryption

```java
@Entity
@Table(name = "customers")
public class Customer {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Encrypted  // Custom annotation for field-level encryption
    @Column(nullable = false)
    private String aadhaarNumber;
    
    @Encrypted
    @Column(nullable = false)
    private String panNumber;
    
    @Column(nullable = false)
    private String email;
    
    @Encrypted
    @Column(nullable = false)
    private String phoneNumber;
}
```

### 2. Audit Trail

```java
@Component
@EventListener
public class AuditEventListener {
    
    @Async
    public void handleCustomerEvent(CustomerEvent event) {
        AuditRecord record = AuditRecord.builder()
            .entityType("CUSTOMER")
            .entityId(event.getCustomerId())
            .action(event.getAction())
            .userId(event.getUserId())
            .timestamp(Instant.now())
            .details(event.getDetails())
            .build();
            
        auditRepository.save(record);
        
        // Send to external audit system
        externalAuditService.sendAuditRecord(record);
    }
}
```

## Compliance Features

### 1. RBI Compliance

```java
@Component
public class RBIComplianceService {
    
    public void validateLoanCompliance(LoanApplication application) {
        // Check loan-to-value ratio
        if (application.getLtvRatio() > RBI_MAX_LTV_RATIO) {
            throw new ComplianceException("LTV ratio exceeds RBI limits");
        }
        
        // Validate customer eligibility
        validateCustomerEligibility(application.getCustomerId());
        
        // Check exposure limits
        validateExposureLimits(application);
        
        // Generate compliance report
        generateComplianceReport(application);
    }
    
    private void validateExposureLimits(LoanApplication application) {
        BigDecimal totalExposure = loanRepository
            .getTotalExposureByCustomer(application.getCustomerId());
            
        BigDecimal proposedExposure = totalExposure.add(application.getAmount());
        
        if (proposedExposure.compareTo(SINGLE_CUSTOMER_EXPOSURE_LIMIT) > 0) {
            throw new ComplianceException("Single customer exposure limit exceeded");
        }
    }
}
```

### 2. Data Localization

```yaml
# application-production.yml
spring:
  datasource:
    url: jdbc:postgresql://in-mumbai-db.financial.com:5432/nbfc_core
    # Ensure database is hosted in India
  
  jpa:
    properties:
      hibernate:
        # Enable encryption at rest
        encrypt_at_rest: true
        encryption_key_provider: com.financial.encryption.HSMKeyProvider

# Kafka configuration for data localization
kafka:
  bootstrap-servers: in-mumbai-kafka.financial.com:9092
  security:
    protocol: SASL_SSL
    sasl:
      mechanism: SCRAM-SHA-512
```

## Testing Strategy

### 1. Unit Tests

```java
@ExtendWith(MockitoExtension.class)
class LoanServiceTest {
    
    @Mock
    private RiskEngine riskEngine;
    
    @Mock
    private LoanRepository loanRepository;
    
    @InjectMocks
    private LoanService loanService;
    
    @Test
    void shouldCreateLoanApplication_WhenRiskScoreIsAcceptable() {
        // Given
        CreateLoanRequest request = CreateLoanRequest.builder()
            .customerId(1L)
            .amount(new BigDecimal("500000"))
            .monthlyIncome(new BigDecimal("100000"))
            .build();
            
        RiskScore riskScore = new RiskScore(0.75, RiskCategory.LOW);
        when(riskEngine.calculateRisk(request)).thenReturn(riskScore);
        
        // When
        LoanApplication result = loanService.processLoanApplication(request);
        
        // Then
        assertThat(result.getStatus()).isEqualTo(LoanStatus.UNDER_REVIEW);
        assertThat(result.getRiskScore()).isEqualTo(riskScore);
        verify(loanRepository).save(any(LoanApplication.class));
    }
}
```

### 2. Integration Tests

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class CustomerControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:14")
            .withDatabaseName("nbfc_test")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreateCustomer_WithValidKYCDocuments() {
        // Given
        CreateCustomerRequest request = CreateCustomerRequest.builder()
            .name("John Doe")
            .email("john.doe@example.com")
            .phoneNumber("+919876543210")
            .aadhaarNumber("123456789012")
            .panNumber("ABCDE1234F")
            .kycDocuments(createValidKYCDocuments())
            .build();
        
        // When
        ResponseEntity<Customer> response = restTemplate.postForEntity(
            "/api/customers", request, Customer.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getName()).isEqualTo("John Doe");
    }
}
```

## Deployment

### 1. Docker Configuration

```dockerfile
FROM openjdk:17-jre-slim

# Add non-root user
RUN addgroup --system --gid 1001 financial && \
    adduser --system --uid 1001 --gid 1001 financial

# Copy application
COPY target/nbfc-core-*.jar /app/nbfc-core.jar

# Set ownership
RUN chown -R financial:financial /app

# Switch to non-root user
USER financial

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "/app/nbfc-core.jar"]
```

### 2. Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nbfc-core
  namespace: financial-services
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nbfc-core
  template:
    metadata:
      labels:
        app: nbfc-core
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: nbfc-core
        image: your-registry/nbfc-core:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: nbfc-secrets
              key: database-password
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Monitoring and Observability

### 1. Application Metrics

```java
@Component
public class LoanMetrics {
    
    private final Counter loanApplicationsTotal;
    private final Timer loanProcessingTime;
    private final Gauge activeLoanAmount;
    
    public LoanMetrics(MeterRegistry meterRegistry) {
        this.loanApplicationsTotal = Counter.builder("loan_applications_total")
            .description("Total number of loan applications")
            .tag("status", "all")
            .register(meterRegistry);
            
        this.loanProcessingTime = Timer.builder("loan_processing_duration")
            .description("Time taken to process loan applications")
            .register(meterRegistry);
            
        this.activeLoanAmount = Gauge.builder("active_loan_amount")
            .description("Total amount of active loans")
            .register(meterRegistry, this, LoanMetrics::getTotalActiveLoanAmount);
    }
    
    public void recordLoanApplication(String status) {
        loanApplicationsTotal.increment(Tags.of("status", status));
    }
    
    public Timer.Sample startProcessingTimer() {
        return Timer.start(loanProcessingTime);
    }
}
```

### 2. Custom Health Indicators

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    private final DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("status", "UP")
                    .build();
            }
        } catch (SQLException e) {
            return Health.down()
                .withDetail("database", "PostgreSQL")
                .withDetail("error", e.getMessage())
                .build();
        }
        
        return Health.down()
            .withDetail("database", "PostgreSQL")
            .withDetail("status", "Connection invalid")
            .build();
    }
}
```

## CI/CD Pipeline

The NBFC Core system uses the financial services CI/CD pipeline with additional specific checks:

- **Financial Compliance**: RBI NBFC guidelines validation
- **Data Security**: PII detection and encryption verification
- **Performance Testing**: Load testing for loan processing
- **Disaster Recovery**: Automated backup and recovery testing

See the main [CI/CD Pipeline documentation](../../.github/workflows/spring-boot-ci.yml) for complete pipeline configuration.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Ensure all tests pass (`mvn test`)
4. Run security scans (`mvn spotbugs:check`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Support

For questions and support:
- 📧 Email: nbfc-core-support@financial.com
- 📖 Documentation: [Internal Wiki](https://wiki.financial.com/nbfc-core)
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/nbfc-core/issues)