package com.example.store.dto;

import lombok.*;
import java.util.List;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartResponse {

    private Long cartId;
    private List<CartItemResponse> items;
    private Double totalPrice;


    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CartItemResponse {
        private Long itemId;
        private Long productId;
        private String productName;
        private Double price;
        private Integer quantity;
        private Double subtotal; // price × quantity
    }
}