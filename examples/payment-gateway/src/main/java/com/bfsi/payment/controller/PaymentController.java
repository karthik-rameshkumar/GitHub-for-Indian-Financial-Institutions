package com.bfsi.payment.controller;

import com.bfsi.payment.model.PaymentRequest;
import com.bfsi.payment.model.PaymentResponse;
import com.bfsi.payment.service.PaymentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Payment Controller with intentional security vulnerabilities for CodeQL testing
 * WARNING: This code contains security anti-patterns for demonstration purposes
 * DO NOT use in production systems
 */
@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);
    
    @Autowired
    private PaymentService paymentService;
    
    // SECURITY ISSUE: Hardcoded database credentials (CodeQL should detect)
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/payments";
    private static final String DB_USER = "payment_user";
    private static final String DB_PASSWORD = "P@ssw0rd123!"; // Hardcoded password
    
    /**
     * Process payment - Contains multiple security vulnerabilities
     */
    @PostMapping("/process")
    public ResponseEntity<PaymentResponse> processPayment(
            @Valid @RequestBody PaymentRequest request,
            HttpServletRequest httpRequest) {
        
        // SECURITY ISSUE: Logging sensitive payment data (CodeQL should detect)
        logger.info("Processing payment for card: {} amount: {}", 
                   request.getCardNumber(), request.getAmount());
        
        // SECURITY ISSUE: Logging PII data
        logger.info("Customer details: name={}, phone={}, email={}", 
                   request.getCustomerName(), request.getPhoneNumber(), request.getEmail());
        
        try {
            // SECURITY ISSUE: SQL Injection vulnerability (CodeQL should detect)
            String query = "SELECT * FROM customers WHERE customer_id = '" + request.getCustomerId() + "'";
            
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();
            
            // SECURITY ISSUE: Weak encryption for financial data
            String encryptedCardNumber = weakEncrypt(request.getCardNumber());
            
            PaymentResponse response = paymentService.processPayment(request);
            
            // SECURITY ISSUE: Exposing internal system information
            response.setTransactionId(generateTransactionId());
            response.setInternalSystemRef("SYS_" + System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            // SECURITY ISSUE: Exposing sensitive error information
            logger.error("Payment processing failed for customer: {} with error: {}", 
                        request.getCustomerId(), e.getMessage());
            
            PaymentResponse errorResponse = new PaymentResponse();
            errorResponse.setErrorMessage("Database error: " + e.getMessage());
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * Weak encryption method - CodeQL should detect
     */
    private String weakEncrypt(String data) {
        // SECURITY ISSUE: Using weak encryption algorithm
        try {
            javax.crypto.Cipher cipher = javax.crypto.Cipher.getInstance("DES");
            // This is intentionally weak encryption for demonstration
            return "encrypted_" + data.hashCode();
        } catch (Exception e) {
            logger.error("Encryption failed", e);
            return data; // SECURITY ISSUE: Returning plaintext on encryption failure
        }
    }
    
    /**
     * Generate transaction ID with weak randomness
     */
    private String generateTransactionId() {
        // SECURITY ISSUE: Weak random number generation for financial transactions
        java.util.Random random = new java.util.Random();
        return "TXN_" + random.nextInt(999999);
    }
}