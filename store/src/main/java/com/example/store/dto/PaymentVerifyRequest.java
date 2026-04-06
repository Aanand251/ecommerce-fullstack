package com.example.store.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO received FROM the frontend after user completes payment
// Razorpay sends these 3 values to the browser; browser sends them here
// We verify the signature to confirm payment is genuine (not tampered)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentVerifyRequest {

    // Razorpay order ID (same one we created in createPaymentOrder)
    @NotBlank(message = "Razorpay order ID is required")
    private String razorpayOrderId;

    // Razorpay payment ID — assigned after user successfully pays
    @NotBlank(message = "Razorpay payment ID is required")
    private String razorpayPaymentId;

    // Cryptographic signature — Razorpay generates this using HMAC-SHA256
    // We re-compute it on our side and compare to verify authenticity
    @NotBlank(message = "Razorpay signature is required")
    private String razorpaySignature;
}
