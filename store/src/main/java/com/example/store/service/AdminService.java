package com.example.store.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.store.dto.ChangeRoleRequest;
import com.example.store.dto.OrderResponse;
import com.example.store.dto.UserDTO;
import com.example.store.exception.ResourceNotFoundException;
import com.example.store.model.Order;
import com.example.store.model.User;
import com.example.store.repository.OrderRepository;
import com.example.store.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;

    // ─── GET ALL USERS ────────────────────────────────────────────────
    public List<UserDTO> getAllUsers() {
        log.info("Admin fetching all users");
        return userRepository.findAll()
                .stream()
                .map(this::convertToUserDTO)
                .collect(Collectors.toList());
    }

    // ─── GET USER BY ID ───────────────────────────────────────────────
    public UserDTO getUserById(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
        return convertToUserDTO(user);
    }

    // ─── CHANGE USER ROLE ─────────────────────────────────────────────
    public UserDTO changeUserRole(Long userId, ChangeRoleRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        log.info("Changing role for user {} from {} to {}", 
                user.getEmail(), user.getRole(), request.getRole());

        user.setRole(request.getRole());
        User savedUser = userRepository.save(user);

        return convertToUserDTO(savedUser);
    }

    // ─── GET ALL ORDERS ───────────────────────────────────────────────
    public List<OrderResponse> getAllOrders() {
        log.info("Admin fetching all orders");
        return orderRepository.findAll()
                .stream()
                .map(this::convertToOrderResponse)
                .collect(Collectors.toList());
    }

    // ─── HELPER: Convert User to DTO ──────────────────────────────────
    private UserDTO convertToUserDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .createdAt(user.getCreatedAt())
                .build();
    }

    // ─── HELPER: Convert Order to Response ────────────────────────────
    private OrderResponse convertToOrderResponse(Order order) {
        List<OrderResponse.OrderItemResponse> itemResponses =
                order.getItems().stream()
                        .map(item -> OrderResponse.OrderItemResponse.builder()
                                .productId(item.getProduct().getId())
                                .productName(item.getProduct().getName())
                                .quantity(item.getQuantity())
                                .price(item.getPrice())
                                .subtotal(item.getPrice() * item.getQuantity())
                                .build())
                        .collect(Collectors.toList());

        return OrderResponse.builder()
                .orderId(order.getId())
                .status(order.getStatus().name())
                .totalPrice(order.getTotalPrice())
                .shippingAddress(order.getShippingAddress())
                .createdAt(order.getCreatedAt())
                .items(itemResponses)
                .build();
    }
}
