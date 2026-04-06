package com.example.store.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.store.dto.ChangeRoleRequest;
import com.example.store.dto.OrderResponse;
import com.example.store.dto.UserDTO;
import com.example.store.service.AdminService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/**
 * Admin-only endpoints for managing users and viewing all orders.
 * All endpoints require ROLE_ADMIN authority.
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('ROLE_ADMIN')")
public class AdminController {

    private final AdminService adminService;

    // ─── GET ALL ORDERS ───────────────────────────────────────────────
    // GET http://localhost:8081/api/admin/orders
    // Returns all orders in the system (for admin dashboard)
    @GetMapping("/orders")
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(adminService.getAllOrders());
    }

    // ─── GET ALL USERS ────────────────────────────────────────────────
    // GET http://localhost:8081/api/admin/users
    // Returns all registered users (without passwords)
    @GetMapping("/users")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    // ─── GET USER BY ID ───────────────────────────────────────────────
    // GET http://localhost:8081/api/admin/users/1
    @GetMapping("/users/{id}")
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getUserById(id));
    }

    // ─── CHANGE USER ROLE ─────────────────────────────────────────────
    // PUT http://localhost:8081/api/admin/users/1/role
    // Body: { "role": "ROLE_ADMIN" }
    // Changes a user's role (e.g., promote to admin or demote to user)
    @PutMapping("/users/{id}/role")
    public ResponseEntity<UserDTO> changeUserRole(
            @PathVariable Long id,
            @Valid @RequestBody ChangeRoleRequest request) {
        return ResponseEntity.ok(adminService.changeUserRole(id, request));
    }
}
