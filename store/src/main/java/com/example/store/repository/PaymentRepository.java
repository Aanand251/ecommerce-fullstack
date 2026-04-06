package com.example.store.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.store.model.Order;
import com.example.store.model.Payment;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    // Find a payment record using Razorpay's order ID
    // Used during payment verification — we look up the payment by razorpayOrderId
    // Returns Optional because the record might not exist (tampered request)
    // Spring generates: SELECT * FROM payments WHERE razorpay_order_id = ?
    Optional<Payment> findByRazorpayOrderId(String razorpayOrderId);

    // Find payment by our internal Order entity
    // Used to check payment status for a given order
    Optional<Payment> findByOrder(Order order);

    // Find payment by our internal order ID
    // Used for GET /api/orders/{id}/payment endpoint
    Optional<Payment> findByOrderId(Long orderId);

    // Check if payment already exists for an order
    // Used to prevent duplicate payment creation
    boolean existsByOrderId(Long orderId);
}
