package com.example.store.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO sent to the frontend after creating a Razorpay order
// Frontend uses these details to open the Razorpay checkout popup
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentOrderResponse {

    // Razorpay's order ID — frontend needs this to open checkout
    private String razorpayOrderId;

    // Amount in paise (1 rupee = 100 paise), e.g. ₹999.99 → 99999
    private Integer amount;

    // Currency code — "INR" for Indian Rupee
    private String currency;

    // Our internal order ID stored in the DB
    private Long orderId;

    // Razorpay public Key ID — frontend uses this to initialise SDK
    // This is SAFE to expose (it's public by design)
    private String keyId;
}
