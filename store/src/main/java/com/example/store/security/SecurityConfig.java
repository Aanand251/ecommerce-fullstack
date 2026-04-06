package com.example.store.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

import lombok.RequiredArgsConstructor;

/**
 * Security configuration for the application.
 *
 * Filter Chain Order:
 * 1. RequestLoggingFilter (Order 0) - Logs all requests
 * 2. RateLimitFilter (Order 1) - Rate limits requests
 * 3. JwtAuthFilter - Authenticates JWT tokens
 * 4. Spring Security Filters
 *
 * Route Protection:
 * - Public: /api/auth/**, GET /api/products/**, GET /api/categories/**, Swagger
 * - Admin Only: /api/admin/**, POST/PUT/DELETE products & categories
 * - Authenticated: /api/cart/**, /api/orders/**, /api/payments/**
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final RateLimitFilter rateLimitFilter;
    private final RequestLoggingFilter requestLoggingFilter;

    @Value("${cors.allowed.origins:http://localhost:*,http://127.0.0.1:*,https://*.vercel.app}")
    private String allowedOrigins;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .authorizeHttpRequests(auth -> auth
                        // ─── PUBLIC ENDPOINTS ─────────────────────────────
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/products/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/categories/**").permitAll()

                        // ─── ADMIN ONLY ENDPOINTS ─────────────────────────
                        // Admin routes — full access to admin panel
                        .requestMatchers("/api/admin/**").hasAuthority("ROLE_ADMIN")
                        // Product management — only admin can create/update/delete
                        .requestMatchers(HttpMethod.POST, "/api/products/**").hasAuthority("ROLE_ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/products/**").hasAuthority("ROLE_ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/products/**").hasAuthority("ROLE_ADMIN")
                        // Category management — only admin can create/update/delete
                        .requestMatchers(HttpMethod.POST, "/api/categories/**").hasAuthority("ROLE_ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/categories/**").hasAuthority("ROLE_ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/categories/**").hasAuthority("ROLE_ADMIN")

                        // ─── AUTHENTICATED ENDPOINTS ──────────────────────
                        // Payment routes — any logged-in user can pay
                        .requestMatchers("/api/payments/**").authenticated()
                        // Cart routes — any logged-in user
                        .requestMatchers("/api/cart/**").authenticated()
                        // Order routes — any logged-in user
                        .requestMatchers("/api/orders/**").authenticated()

                        // ─── SWAGGER UI ───────────────────────────────────
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/v3/api-docs/**"
                        ).permitAll()

                        // ─── ALL OTHER REQUESTS ───────────────────────────
                        .anyRequest().authenticated()
                )
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // Filter chain: RequestLogging → RateLimit → JWT Auth → Security
                .addFilterBefore(requestLoggingFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();
                // Allow origins from environment variable or default to localhost + Vercel
                List<String> origins = Arrays.asList(allowedOrigins.split(","));
                configuration.setAllowedOriginPatterns(origins);
                configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
                configuration.setAllowedHeaders(List.of("*"));
                configuration.setExposedHeaders(List.of("Authorization", "Content-Type"));
                configuration.setAllowCredentials(true);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}