package com.example.store.model;

// Enum for payment lifecycle — just like OrderStatus, only these values are allowed
// CREATED  → Razorpay order was created, user hasn't paid yet
// SUCCESS  → Payment verified and confirmed ✅
// FAILED   → Payment verification failed ❌
public enum PaymentStatus {
    CREATED,
    SUCCESS,
    FAILED
}
