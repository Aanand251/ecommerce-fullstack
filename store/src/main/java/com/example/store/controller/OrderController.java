package com.example.store.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.store.dto.OrderRequest;
import com.example.store.dto.OrderResponse;
import com.example.store.dto.PaymentStatusResponse;
import com.example.store.model.OrderStatus;
import com.example.store.model.Payment;
import com.example.store.service.OrderService;
import com.example.store.service.PaymentService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final PaymentService paymentService;

    // POST http://localhost:8081/api/orders/place
    @PostMapping("/place")
    public ResponseEntity<OrderResponse> placeOrder(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody OrderRequest request) {
        OrderResponse order = orderService.placeOrder(
                userDetails.getUsername(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(order);
    }

    // GET http://localhost:8081/api/orders/my
    @GetMapping("/my")
    public ResponseEntity<List<OrderResponse>> getMyOrders(
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(
                orderService.getMyOrders(
                        userDetails.getUsername()));
    }

    // GET http://localhost:8081/api/orders/1
    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponse> getOrderById(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long orderId) {
        return ResponseEntity.ok(
                orderService.getOrderById(
                        userDetails.getUsername(), orderId));
    }

    // GET http://localhost:8081/api/orders/1/payment
    // Get payment status for a specific order
    @GetMapping("/{orderId}/payment")
    public ResponseEntity<PaymentStatusResponse> getOrderPayment(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long orderId) {
        // First verify user owns this order
        orderService.getOrderById(userDetails.getUsername(), orderId);
        
        Payment payment = paymentService.getPaymentByOrderId(orderId);
        
        PaymentStatusResponse response = PaymentStatusResponse.builder()
                .paymentId(payment.getId())
                .orderId(orderId)
                .status(payment.getStatus())
                .razorpayOrderId(payment.getRazorpayOrderId())
                .razorpayPaymentId(payment.getRazorpayPaymentId())
                .amountInPaise(payment.getAmount())
                .amountInRupees(payment.getAmount() / 100.0)
                .currency("INR")
                .createdAt(payment.getCreatedAt())
                .build();
        
        return ResponseEntity.ok(response);
    }

    // PUT http://localhost:8081/api/orders/1/status?status=SHIPPED
    @PutMapping("/{orderId}/status")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<OrderResponse> updateStatus(
            @PathVariable Long orderId,
            @RequestParam OrderStatus status) {
        return ResponseEntity.ok(
                orderService.updateOrderStatus(orderId, status));
    }
}