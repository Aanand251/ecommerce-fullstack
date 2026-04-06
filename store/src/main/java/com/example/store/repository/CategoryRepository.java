package com.example.store.repository;

import com.example.store.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    // Spring generates: SELECT * FROM categories WHERE name = ?
    Optional<Category> findByName(String name);
}