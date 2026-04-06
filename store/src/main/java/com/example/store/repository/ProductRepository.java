package com.example.store.repository;

import com.example.store.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product>  findByCategoryId(Long CategoryId);

    List<Product> findByNameContainingIgnoreCase(String keyword);

    List<Product> findByPriceBetween(Double minPrice, Double maxPrice);

    List<Product> findByStockGreaterThan(Integer stock);

}
