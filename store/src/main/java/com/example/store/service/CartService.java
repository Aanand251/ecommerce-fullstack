package com.example.store.service;

import com.example.store.dto.CartItemRequest;
import com.example.store.dto.CartResponse;
import com.example.store.model.*;
import com.example.store.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CartService {

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;


    public CartResponse getCart(String email) {
        User user = getUser(email);
        Cart cart = getOrCreateCart(user);
        return convertToResponse(cart);
    }


    public CartResponse addToCart(String email,
                                  CartItemRequest request) {
        User user = getUser(email);
        Cart cart = getOrCreateCart(user);


        Product product = productRepository
                .findById(request.getProductId())
                .orElseThrow(() ->
                        new RuntimeException("Product not found!"));


        if (product.getStock() < request.getQuantity()) {
            throw new RuntimeException(
                    "out of stock "
                            + product.getStock() + " available!.");
        }


        Optional<CartItem> existingItem = cart.getItems()
                .stream()
                .filter(item -> item.getProduct()
                        .getId().equals(request.getProductId()))
                .findFirst();

        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(
                    item.getQuantity() + request.getQuantity());
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .product(product)
                    .quantity(request.getQuantity())
                    .price(product.getPrice())
                    .build();
            cart.getItems().add(newItem);
        }

        cartRepository.save(cart);
        return convertToResponse(cart);
    }


    public CartResponse removeFromCart(String email, Long itemId) {
        User user = getUser(email);
        Cart cart = getOrCreateCart(user);


        cart.getItems().removeIf(
                item -> item.getId().equals(itemId));

        cartRepository.save(cart);
        return convertToResponse(cart);
    }


    public void clearCart(String email) {
        User user = getUser(email);
        Cart cart = getOrCreateCart(user);
        cart.getItems().clear();
        cartRepository.save(cart);
    }


    public Cart getOrCreateCart(User user) {
        return cartRepository.findByUser(user)
                .orElseGet(() -> {

                    Cart newCart = Cart.builder()
                            .user(user)
                            .build();
                    return cartRepository.save(newCart);
                });
    }


    public User getUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found!"));
    }


    private CartResponse convertToResponse(Cart cart) {
        List<CartResponse.CartItemResponse> itemResponses =
                cart.getItems().stream()
                        .map(item -> CartResponse.CartItemResponse.builder()
                                .itemId(item.getId())
                                .productId(item.getProduct().getId())
                                .productName(item.getProduct().getName())
                                .price(item.getPrice())
                                .quantity(item.getQuantity())
                                // subtotal = price × quantity
                                .subtotal(item.getPrice() * item.getQuantity())
                                .build())
                        .collect(Collectors.toList());

        Double totalPrice = itemResponses.stream()
                .mapToDouble(CartResponse.CartItemResponse::getSubtotal)
                .sum();

        return CartResponse.builder()
                .cartId(cart.getId())
                .items(itemResponses)
                .totalPrice(totalPrice)
                .build();
    }
}