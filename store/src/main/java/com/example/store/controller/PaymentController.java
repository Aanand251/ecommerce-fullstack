package com.example.store.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.store.dto.PaymentOrderResponse;
import com.example.store.dto.PaymentVerifyRequest;
import com.example.store.model.Payment;
import com.example.store.service.PaymentService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

// Handles the two-step payment flow:
// Step 1 → POST /api/payments/create/{orderId}  → creates Razorpay order
// Step 2 → POST /api/payments/verify            → verifies payment after user pays
// Step 3 → GET  /api/payments/status/{orderId}  → check payment status
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    // ─── CREATE PAYMENT ORDER ─────────────────────────────────────────
    // Called when user clicks "Pay Now"
    // Returns Razorpay order details — frontend uses them to open the popup
    //
    // POST http://localhost:8081/api/payments/create/1
    // Headers: Authorization: Bearer <token>
    @PostMapping("/create/{orderId}")
    public ResponseEntity<PaymentOrderResponse> createPayment(
            @PathVariable Long orderId) {
        return ResponseEntity.ok(paymentService.createPaymentOrder(orderId));
    }

    // ─── VERIFY PAYMENT ───────────────────────────────────────────────
    // Called after user completes payment in the Razorpay popup
    // Frontend sends back the 3 IDs Razorpay gave it
    // We verify the signature — if valid, order is CONFIRMED
    //
    // POST http://localhost:8081/api/payments/verify
    // Headers: Authorization: Bearer <token>
    // Body: { "razorpayOrderId": "...", "razorpayPaymentId": "...", "razorpaySignature": "..." }
    @PostMapping("/verify")
    public ResponseEntity<Map<String, Object>> verifyPayment(
            @Valid @RequestBody PaymentVerifyRequest request) {

        boolean isValid = paymentService.verifyPayment(request);

        // Payment verified successfully — return success message
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Payment successful! Your order is confirmed."
        ));
    }

    // ─── GET PAYMENT STATUS ───────────────────────────────────────────
    // Check the current payment status for an order
    //
    // GET http://localhost:8081/api/payments/status/1
    // Headers: Authorization: Bearer <token>
    @GetMapping("/status/{orderId}")
    public ResponseEntity<Map<String, Object>> getPaymentStatus(
            @PathVariable Long orderId) {

        Payment payment = paymentService.getPaymentByOrderId(orderId);

        return ResponseEntity.ok(Map.of(
                "orderId", orderId,
                "status", payment.getStatus().name(),
                "razorpayOrderId", payment.getRazorpayOrderId() != null ? payment.getRazorpayOrderId() : "",
                "razorpayPaymentId", payment.getRazorpayPaymentId() != null ? payment.getRazorpayPaymentId() : "",
                "amount", payment.getAmount(),
                "amountInRupees", payment.getAmount() / 100.0,
                "createdAt", payment.getCreatedAt().toString()
        ));
    }

    // ─── CHECK IF PAYMENT EXISTS ──────────────────────────────────────
    // Quick check if an order has a payment record
    //
    // GET http://localhost:8081/api/payments/exists/1
    // Headers: Authorization: Bearer <token>
    @GetMapping("/exists/{orderId}")
    public ResponseEntity<Map<String, Object>> checkPaymentExists(
            @PathVariable Long orderId) {

        boolean exists = paymentService.hasPayment(orderId);

        return ResponseEntity.ok(Map.of(
                "orderId", orderId,
                "hasPayment", exists
        ));
    }
}
