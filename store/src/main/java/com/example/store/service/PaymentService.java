package com.example.store.service;

import com.example.store.exception.DuplicatePaymentException;
import com.example.store.exception.PaymentException;
import com.example.store.exception.ResourceNotFoundException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.example.store.dto.PaymentOrderResponse;
import com.example.store.dto.PaymentVerifyRequest;
import com.example.store.model.Order;
import com.example.store.model.OrderStatus;
import com.example.store.model.Payment;
import com.example.store.model.PaymentStatus;
import com.example.store.repository.OrderRepository;
import com.example.store.repository.PaymentRepository;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// @Slf4j (Lombok) → auto-creates a logger named 'log'
// Use: log.info("message"), log.error("message"), log.debug("message")
@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;

    // @Value reads values from application.properties at startup
    @Value("${razorpay.key.id}")
    private String keyId;

    @Value("${razorpay.key.secret}")
    private String keySecret;

    // ─── STEP 1: CREATE RAZORPAY ORDER ───────────────────────────────
    // Called when user clicks "Proceed to Payment"
    // Creates an order on Razorpay's server and saves it in our DB
    // Returns details the frontend needs to open the payment popup
    public PaymentOrderResponse createPaymentOrder(Long orderId) {
        log.info("Creating Razorpay payment order for orderId: {}", orderId);

        // Fetch our order from DB
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));

        // Check if payment already exists for this order
        if (paymentRepository.existsByOrderId(orderId)) {
            // Check if the existing payment is already successful
            Payment existingPayment = paymentRepository.findByOrderId(orderId).get();
            if (existingPayment.getStatus() == PaymentStatus.SUCCESS) {
                throw new DuplicatePaymentException("Order " + orderId + " is already paid");
            }
            // If payment exists but failed, return the existing Razorpay order details
            // so user can retry payment with the same order
            if (existingPayment.getStatus() == PaymentStatus.CREATED) {
                log.info("Returning existing payment order for orderId: {}", orderId);
                return PaymentOrderResponse.builder()
                        .razorpayOrderId(existingPayment.getRazorpayOrderId())
                        .amount(existingPayment.getAmount())
                        .currency("INR")
                        .orderId(orderId)
                        .keyId(keyId)
                        .build();
            }
        }

        // Validate order status — can only pay for PENDING orders
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new PaymentException(
                    "Cannot create payment for order with status: " + order.getStatus(),
                    "INVALID_ORDER_STATUS"
            );
        }

        // Convert rupees to paise — Razorpay always works in smallest unit
        // ₹999.99 → multiply by 100 → 99999 paise
        int amountInPaise = (int) (order.getTotalPrice() * 100);

        try {
            // Create Razorpay client using our API keys
            RazorpayClient razorpayClient = new RazorpayClient(keyId, keySecret);

            // Build the order options JSON that Razorpay expects
            JSONObject orderOptions = new JSONObject();
            orderOptions.put("amount", amountInPaise);   // must be in paise
            orderOptions.put("currency", "INR");          // Indian Rupee
            orderOptions.put("receipt", "rcpt_" + orderId); // our reference ID

            // Make API call to Razorpay — creates an order on their server
            com.razorpay.Order razorpayOrder = razorpayClient.orders.create(orderOptions);
            String razorpayOrderId = razorpayOrder.get("id");

            log.info("Razorpay order created: {}", razorpayOrderId);

            // Save payment record in our DB with CREATED status
            Payment payment = Payment.builder()
                    .order(order)
                    .razorpayOrderId(razorpayOrderId)
                    .amount(amountInPaise)
                    .status(PaymentStatus.CREATED)
                    .build();
            paymentRepository.save(payment);

            // Return all details the frontend needs to open checkout popup
            return PaymentOrderResponse.builder()
                    .razorpayOrderId(razorpayOrderId)
                    .amount(amountInPaise)
                    .currency("INR")
                    .orderId(orderId)
                    .keyId(keyId) // public key — safe to send to frontend
                    .build();

        } catch (RazorpayException e) {
            log.error("Failed to create Razorpay order for orderId: {}", orderId, e);
            throw new PaymentException("Payment order creation failed: " + e.getMessage(), "RAZORPAY_CREATE_FAILED", e);
        }
    }

    // ─── STEP 2: VERIFY PAYMENT ───────────────────────────────────────
    // Called after user completes payment in the popup
    // Verifies the payment is genuine by checking Razorpay's signature
    // This step is CRITICAL — without it, fake payments can fool the system
    public boolean verifyPayment(PaymentVerifyRequest request) {
        log.info("Verifying payment for razorpayOrderId: {}", request.getRazorpayOrderId());

        // Validate request parameters
        if (request.getRazorpayOrderId() == null || request.getRazorpayOrderId().isBlank()) {
            throw new PaymentException("Razorpay order ID is required", "MISSING_ORDER_ID");
        }
        if (request.getRazorpayPaymentId() == null || request.getRazorpayPaymentId().isBlank()) {
            throw new PaymentException("Razorpay payment ID is required", "MISSING_PAYMENT_ID");
        }
        if (request.getRazorpaySignature() == null || request.getRazorpaySignature().isBlank()) {
            throw new PaymentException("Razorpay signature is required", "MISSING_SIGNATURE");
        }

        // Find our payment record first
        Payment payment = paymentRepository
                .findByRazorpayOrderId(request.getRazorpayOrderId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Payment", "razorpayOrderId", request.getRazorpayOrderId()));

        // Check if already verified
        if (payment.getStatus() == PaymentStatus.SUCCESS) {
            log.info("Payment already verified for: {}", request.getRazorpayOrderId());
            return true;
        }

        try {
            // Build the JSON object Razorpay's Utils.verifyPaymentSignature expects
            JSONObject attributes = new JSONObject();
            attributes.put("razorpay_order_id", request.getRazorpayOrderId());
            attributes.put("razorpay_payment_id", request.getRazorpayPaymentId());
            attributes.put("razorpay_signature", request.getRazorpaySignature());

            // Razorpay recomputes HMAC-SHA256 using keySecret + orderId + paymentId
            // If signatures match → payment is genuine
            // If they don't match → throws RazorpayException (tampered/fake)
            Utils.verifyPaymentSignature(attributes, keySecret);

            // ✅ Signature valid — payment is genuine
            log.info("Payment signature verified successfully for: {}", request.getRazorpayPaymentId());

            // Update payment record with payment ID and mark SUCCESS
            payment.setRazorpayPaymentId(request.getRazorpayPaymentId());
            payment.setRazorpaySignature(request.getRazorpaySignature());
            payment.setStatus(PaymentStatus.SUCCESS);
            paymentRepository.save(payment);

            // Also update the Order status to CONFIRMED
            Order order = payment.getOrder();
            order.setStatus(OrderStatus.CONFIRMED);
            orderRepository.save(order);

            log.info("Order {} confirmed after successful payment", order.getId());
            return true;

        } catch (RazorpayException e) {
            // ❌ Signature invalid — payment is fake or tampered
            log.error("Payment verification FAILED for razorpayOrderId: {}", request.getRazorpayOrderId());

            // Mark the payment as FAILED in our DB
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);

            throw new PaymentException(
                    "Payment verification failed. Signature mismatch.",
                    "SIGNATURE_VERIFICATION_FAILED",
                    e
            );
        }
    }

    // ─── STEP 3: GET PAYMENT STATUS ───────────────────────────────────
    // Returns the current payment status for a given order
    // Used to check if payment exists and its current status
    public Payment getPaymentByOrderId(Long orderId) {
        log.info("Fetching payment status for orderId: {}", orderId);

        // First verify the order exists
        if (!orderRepository.existsById(orderId)) {
            throw new ResourceNotFoundException("Order", orderId);
        }

        return paymentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Payment", "orderId", orderId.toString()));
    }

    // ─── STEP 4: GET PAYMENT BY RAZORPAY ORDER ID ─────────────────────
    // Fetch payment details using Razorpay's order ID
    public Payment getPaymentByRazorpayOrderId(String razorpayOrderId) {
        log.info("Fetching payment by razorpayOrderId: {}", razorpayOrderId);

        return paymentRepository.findByRazorpayOrderId(razorpayOrderId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Payment", "razorpayOrderId", razorpayOrderId));
    }

    // ─── STEP 5: CHECK IF ORDER HAS PAYMENT ───────────────────────────
    public boolean hasPayment(Long orderId) {
        return paymentRepository.existsByOrderId(orderId);
    }
}
