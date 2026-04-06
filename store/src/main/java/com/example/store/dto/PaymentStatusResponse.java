package com.example.store.dto;

import java.time.LocalDateTime;

import com.example.store.model.PaymentStatus;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for returning payment status information.
 * Used by GET /api/payments/status/{orderId} and GET /api/orders/{id}/payment
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentStatusResponse {

    private Long paymentId;
    private Long orderId;
    private PaymentStatus status;
    private String razorpayOrderId;
    private String razorpayPaymentId;
    private Integer amountInPaise;
    private Double amountInRupees;
    private String currency;
    private LocalDateTime createdAt;
    private String message;
}
