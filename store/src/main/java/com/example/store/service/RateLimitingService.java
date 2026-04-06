package com.example.store.service;

import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

/**
 * Simple in-memory rate limiting service using sliding window algorithm.
 * No external dependencies required.
 *
 * Rate Limits Applied:
 * - Auth endpoints (login/register): 5 requests per minute per IP
 * - General API: 100 requests per minute per IP
 * - Admin endpoints: 50 requests per minute per IP
 */
@Slf4j
@Service
public class RateLimitingService {

    // Rate limit configurations
    private static final int AUTH_LIMIT = 5;          // 5 requests per minute
    private static final int API_LIMIT = 100;         // 100 requests per minute
    private static final int ADMIN_LIMIT = 50;        // 50 requests per minute
    private static final long WINDOW_MS = 60_000;     // 1 minute window

    // Token buckets per IP address
    private final ConcurrentMap<String, RateLimitBucket> authBuckets = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, RateLimitBucket> apiBuckets = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, RateLimitBucket> adminBuckets = new ConcurrentHashMap<>();

    // Blocked IPs after too many failed attempts (brute force protection)
    private final ConcurrentMap<String, Long> blockedIps = new ConcurrentHashMap<>();

    /**
     * Check if auth request is allowed (stricter limit)
     * 5 requests per minute to prevent brute force attacks
     */
    public boolean isAuthRequestAllowed(String ipAddress) {
        // Check if IP is blocked
        if (isIpBlocked(ipAddress)) {
            log.warn("Blocked IP attempted auth: {}", ipAddress);
            return false;
        }

        RateLimitBucket bucket = authBuckets.computeIfAbsent(
                ipAddress, k -> new RateLimitBucket(AUTH_LIMIT, WINDOW_MS));
        boolean allowed = bucket.tryConsume();

        if (!allowed) {
            log.warn("Rate limit exceeded for auth endpoint - IP: {}", ipAddress);
        }

        return allowed;
    }

    /**
     * Check if general API request is allowed
     * 100 requests per minute
     */
    public boolean isApiRequestAllowed(String ipAddress) {
        RateLimitBucket bucket = apiBuckets.computeIfAbsent(
                ipAddress, k -> new RateLimitBucket(API_LIMIT, WINDOW_MS));
        boolean allowed = bucket.tryConsume();

        if (!allowed) {
            log.warn("Rate limit exceeded for API - IP: {}", ipAddress);
        }

        return allowed;
    }

    /**
     * Check if admin request is allowed
     * 50 requests per minute
     */
    public boolean isAdminRequestAllowed(String ipAddress) {
        RateLimitBucket bucket = adminBuckets.computeIfAbsent(
                ipAddress, k -> new RateLimitBucket(ADMIN_LIMIT, WINDOW_MS));
        boolean allowed = bucket.tryConsume();

        if (!allowed) {
            log.warn("Rate limit exceeded for admin endpoint - IP: {}", ipAddress);
        }

        return allowed;
    }

    /**
     * Block an IP address for a specified duration (e.g., after multiple failed logins)
     */
    public void blockIp(String ipAddress, Duration duration) {
        long unblockTime = System.currentTimeMillis() + duration.toMillis();
        blockedIps.put(ipAddress, unblockTime);
        log.warn("IP blocked until {}: {}", unblockTime, ipAddress);
    }

    /**
     * Check if an IP is currently blocked
     */
    public boolean isIpBlocked(String ipAddress) {
        Long unblockTime = blockedIps.get(ipAddress);
        if (unblockTime == null) {
            return false;
        }

        if (System.currentTimeMillis() > unblockTime) {
            blockedIps.remove(ipAddress);
            return false;
        }

        return true;
    }

    /**
     * Get remaining tokens for auth bucket
     */
    public long getRemainingAuthTokens(String ipAddress) {
        RateLimitBucket bucket = authBuckets.get(ipAddress);
        return bucket != null ? bucket.getRemaining() : AUTH_LIMIT;
    }

    /**
     * Simple token bucket implementation for rate limiting.
     * Thread-safe using atomic operations.
     */
    private static class RateLimitBucket {
        private final int maxTokens;
        private final long windowMs;
        private final AtomicInteger tokens;
        private final AtomicLong windowStart;

        public RateLimitBucket(int maxTokens, long windowMs) {
            this.maxTokens = maxTokens;
            this.windowMs = windowMs;
            this.tokens = new AtomicInteger(maxTokens);
            this.windowStart = new AtomicLong(System.currentTimeMillis());
        }

        /**
         * Try to consume one token.
         * Returns true if request is allowed, false if rate limit exceeded.
         */
        public synchronized boolean tryConsume() {
            long now = System.currentTimeMillis();
            long start = windowStart.get();

            // Check if window has expired, reset if so
            if (now - start >= windowMs) {
                tokens.set(maxTokens);
                windowStart.set(now);
            }

            // Try to consume a token
            int currentTokens = tokens.get();
            if (currentTokens > 0) {
                tokens.decrementAndGet();
                return true;
            }

            return false;
        }

        /**
         * Get remaining tokens in current window
         */
        public int getRemaining() {
            long now = System.currentTimeMillis();
            long start = windowStart.get();

            // If window expired, would have full tokens
            if (now - start >= windowMs) {
                return maxTokens;
            }

            return Math.max(0, tokens.get());
        }
    }
}
