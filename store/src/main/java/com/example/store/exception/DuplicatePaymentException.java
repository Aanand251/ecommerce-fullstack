package com.example.store.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Exception for duplicate payment attempts.
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class DuplicatePaymentException extends RuntimeException {

    public DuplicatePaymentException(Long orderId) {
        super("Payment already exists for order: " + orderId);
    }

    public DuplicatePaymentException(String message) {
        super(message);
    }
}