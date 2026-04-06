package com.example.store.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// This entity stores one payment record per order
// Tracks the full lifecycle: CREATED → SUCCESS or FAILED
@Entity
@Table(name = "payments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // One payment belongs to exactly one order
    // @OneToOne = one order ↔ one payment record
    @OneToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    // Razorpay's own order ID — returned when we create a payment order
    // Format: "order_XXXXXXXXXXXXXXXX"
    @Column(name = "razorpay_order_id", unique = true)
    private String razorpayOrderId;

    // Razorpay's payment ID — assigned after user completes payment
    // Format: "pay_XXXXXXXXXXXXXXXX"
    // Null until user actually pays
    @Column(name = "razorpay_payment_id")
    private String razorpayPaymentId;

    // Cryptographic signature for verification
    // Set after successful payment verification
    @Column(name = "razorpay_signature")
    private String razorpaySignature;

    // Amount stored in paise (smallest currency unit)
    // 1 rupee = 100 paise  →  ₹999.99 stored as 99999
    // Razorpay always works in paise
    @Column(nullable = false)
    private Integer amount;

    // Current payment status — defaults to CREATED
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.CREATED;

    // Timestamp when payment record was created
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // @PrePersist runs automatically just before saving to DB
    // Sets createdAt to current time — no manual work needed
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
