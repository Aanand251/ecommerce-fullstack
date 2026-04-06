package com.example.store.security;

import java.io.IOException;

import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.example.store.service.RateLimitingService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Filter to apply rate limiting on specific endpoints.
 *
 * Rate limits:
 * - /api/auth/** : 5 requests per minute (strict, prevents brute force)
 * - /api/admin/** : 50 requests per minute
 * - Other APIs : 100 requests per minute
 *
 * Order(1) ensures this runs early in the filter chain
 */
@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class RateLimitFilter extends OncePerRequestFilter {

    private final RateLimitingService rateLimitingService;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String clientIp = getClientIp(request);
        String requestUri = request.getRequestURI();

        boolean allowed;
        String limitType;

        // Apply different rate limits based on endpoint
        if (requestUri.startsWith("/api/auth/")) {
            allowed = rateLimitingService.isAuthRequestAllowed(clientIp);
            limitType = "auth";
            // Add rate limit headers for auth endpoints
            long remaining = rateLimitingService.getRemainingAuthTokens(clientIp);
            response.setHeader("X-RateLimit-Limit", "5");
            response.setHeader("X-RateLimit-Remaining", String.valueOf(Math.max(0, remaining - 1)));
            response.setHeader("X-RateLimit-Reset", "60");
        } else if (requestUri.startsWith("/api/admin/")) {
            allowed = rateLimitingService.isAdminRequestAllowed(clientIp);
            limitType = "admin";
        } else if (requestUri.startsWith("/api/")) {
            allowed = rateLimitingService.isApiRequestAllowed(clientIp);
            limitType = "api";
        } else {
            // Non-API requests (swagger, static, etc.) - allow without limit
            filterChain.doFilter(request, response);
            return;
        }

        if (!allowed) {
            log.warn("Rate limit exceeded - IP: {}, Type: {}, URI: {}", clientIp, limitType, requestUri);
            sendRateLimitResponse(response, limitType);
            return;
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Extract client IP address, handling proxies/load balancers
     */
    private String getClientIp(HttpServletRequest request) {
        // Check for forwarded headers (when behind proxy/load balancer)
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            // X-Forwarded-For can contain multiple IPs; first one is the client
            return xForwardedFor.split(",")[0].trim();
        }

        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }

        return request.getRemoteAddr();
    }

    /**
     * Send HTTP 429 Too Many Requests response
     */
    private void sendRateLimitResponse(HttpServletResponse response, String limitType) throws IOException {
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setHeader("Retry-After", "60");

        String message;
        if ("auth".equals(limitType)) {
            message = "Too many authentication attempts. Please wait 1 minute before trying again.";
        } else if ("admin".equals(limitType)) {
            message = "Too many admin requests. Please slow down.";
        } else {
            message = "Too many requests. Please try again later.";
        }

        String json = String.format(
                "{\"status\":429,\"error\":\"Too Many Requests\",\"message\":\"%s\",\"code\":\"RATE_LIMIT_EXCEEDED\",\"retryAfter\":60}",
                message);
        response.getWriter().write(json);
    }
}
