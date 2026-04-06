package com.example.store.security;

import java.io.IOException;
import java.util.UUID;

import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingResponseWrapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

/**
 * Filter to log all incoming HTTP requests and outgoing responses.
 *
 * Logs include:
 * - Request ID (for tracing)
 * - HTTP Method and URI
 * - Client IP Address
 * - User Agent
 * - Response Status
 * - Processing Time
 *
 * Order(0) ensures this runs first in the filter chain
 */
@Slf4j
@Component
@Order(0)
public class RequestLoggingFilter extends OncePerRequestFilter {

    // Maximum content length to cache (10KB)
    private static final int MAX_CONTENT_LENGTH = 10240;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        // Skip logging for static resources and health checks
        String uri = request.getRequestURI();
        if (shouldSkipLogging(uri)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Generate unique request ID for tracing
        String requestId = UUID.randomUUID().toString().substring(0, 8);
        long startTime = System.currentTimeMillis();

        // Wrap response to cache content for logging
        ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(response);

        // Add request ID to response header for client-side tracing
        wrappedResponse.setHeader("X-Request-ID", requestId);

        // Extract request details
        String method = request.getMethod();
        String clientIp = getClientIp(request);
        String userAgent = request.getHeader("User-Agent");
        String queryString = request.getQueryString();
        String fullUri = queryString != null ? uri + "?" + queryString : uri;

        // Log incoming request
        log.info("[{}] --> {} {} | IP: {} | UA: {}",
                requestId, method, fullUri, clientIp, truncate(userAgent, 50));

        try {
            // Continue with the filter chain (use original request, wrapped response)
            filterChain.doFilter(request, wrappedResponse);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            int status = wrappedResponse.getStatus();

            // Log response based on status code
            if (status >= 500) {
                log.error("[{}] <-- {} {} | Status: {} | Time: {}ms",
                        requestId, method, uri, status, duration);
            } else if (status >= 400) {
                log.warn("[{}] <-- {} {} | Status: {} | Time: {}ms",
                        requestId, method, uri, status, duration);
            } else {
                log.info("[{}] <-- {} {} | Status: {} | Time: {}ms",
                        requestId, method, uri, status, duration);
            }

            // Log slow requests (> 1 second)
            if (duration > 1000) {
                log.warn("[{}] SLOW REQUEST: {} {} took {}ms", requestId, method, uri, duration);
            }

            // Copy content to response (required for ContentCachingResponseWrapper)
            wrappedResponse.copyBodyToResponse();
        }
    }

    /**
     * Skip logging for certain paths (static resources, health checks, swagger)
     */
    private boolean shouldSkipLogging(String uri) {
        return uri.startsWith("/swagger-ui") ||
               uri.startsWith("/v3/api-docs") ||
               uri.startsWith("/webjars") ||
               uri.startsWith("/favicon.ico") ||
               uri.equals("/actuator/health") ||
               uri.startsWith("/css/") ||
               uri.startsWith("/js/") ||
               uri.startsWith("/images/");
    }

    /**
     * Extract client IP address, handling proxies
     */
    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }

        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }

        return request.getRemoteAddr();
    }

    /**
     * Truncate string to specified length
     */
    private String truncate(String str, int maxLength) {
        if (str == null) return "Unknown";
        return str.length() > maxLength ? str.substring(0, maxLength) + "..." : str;
    }
}
