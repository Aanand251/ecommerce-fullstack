package com.example.store.service;

import com.example.store.dto.OrderRequest;
import com.example.store.dto.OrderResponse;
import com.example.store.exception.EmptyCartException;
import com.example.store.exception.InsufficientStockException;
import com.example.store.exception.ResourceNotFoundException;
import com.example.store.exception.UnauthorizedAccessException;
import com.example.store.model.*;
import com.example.store.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;


    @Transactional
    public OrderResponse placeOrder(String email, OrderRequest request) {
        User user = cartService.getUser(email);
        Cart cart = cartService.getOrCreateCart(user);

        if (cart.getItems().isEmpty()) {
            throw new EmptyCartException();
        }

        List<OrderItem> orderItems = cart.getItems()
                .stream()
                .map(cartItem -> {
                    Product product = cartItem.getProduct();

                    if (product.getStock() < cartItem.getQuantity()) {
                        throw new InsufficientStockException(
                                product.getName(),
                                cartItem.getQuantity(),
                                product.getStock()
                        );
                    }

                    product.setStock(product.getStock() - cartItem.getQuantity());
                    productRepository.save(product);

                    return OrderItem.builder()
                            .product(product)
                            .quantity(cartItem.getQuantity())
                            .price(cartItem.getPrice())
                            .build();
                })
                .collect(Collectors.toList());

        Double totalPrice = orderItems.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();

        Order order = Order.builder()
                .user(user)
                .items(orderItems)
                .totalPrice(totalPrice)
                .shippingAddress(request.getShippingAddress())
                .status(OrderStatus.PENDING)
                .build();

        orderItems.forEach(item -> item.setOrder(order));
        Order savedOrder = orderRepository.save(order);
        cartService.clearCart(email);

        log.info("Order placed successfully. OrderId: {}, User: {}", savedOrder.getId(), email);
        return convertToResponse(savedOrder);
    }


    public List<OrderResponse> getMyOrders(String email) {
        User user = cartService.getUser(email);
        return orderRepository
                .findByUserOrderByCreatedAtDesc(user)
                .stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }


    public OrderResponse getOrderById(String email, Long orderId) {
        User user = cartService.getUser(email);
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));

        if (!order.getUser().getId().equals(user.getId())) {
            throw new UnauthorizedAccessException("Order", orderId);
        }

        return convertToResponse(order);
    }


    public OrderResponse updateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order", orderId));

        order.setStatus(status);
        log.info("Order {} status updated to {}", orderId, status);
        return convertToResponse(orderRepository.save(order));
    }


    private OrderResponse convertToResponse(Order order) {
        List<OrderResponse.OrderItemResponse> itemResponses =
                order.getItems().stream()
                        .map(item -> OrderResponse.OrderItemResponse
                                .builder()
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