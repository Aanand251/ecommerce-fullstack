package com.example.store.controller;

import com.example.store.dto.AuthResponse;
import com.example.store.dto.LoginRequest;
import com.example.store.dto.RegisterRequest;
import com.example.store.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
// All auth routes start with /api/auth
// These are PUBLIC — no JWT needed (defined in SecurityConfig)
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // ─── REGISTER ───
    // POST http://localhost:8081/api/auth/register
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    // ─── LOGIN ───
    // POST http://localhost:8081/api/auth/login
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}
