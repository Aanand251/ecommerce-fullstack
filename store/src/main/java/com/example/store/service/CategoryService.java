package com.example.store.service;

import com.example.store.model.Category;
import com.example.store.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

// CategoryService — moves business logic OUT of the controller
// Rule: Controllers should never directly touch repositories
// Controller → Service → Repository is the correct 3-layer flow
@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    // Get all categories — no pagination needed (categories are few)
    public List<Category> getAllCategories() {
        log.info("Fetching all categories");
        return categoryRepository.findAll();
    }

    // Create a new category — checks for duplicate name before saving
    public Category createCategory(Category category) {
        log.info("Creating category: {}", category.getName());

        // Check if a category with the same name already exists
        if (categoryRepository.findByName(category.getName()).isPresent()) {
            throw new RuntimeException(
                    "Category already exists with name: " + category.getName());
        }

        Category saved = categoryRepository.save(category);
        log.info("Category created with id: {}", saved.getId());
        return saved;
    }

    // Get single category by ID
    public Category getCategoryById(Long id) {
        log.info("Fetching category with id: {}", id);
        return categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + id));
    }

    // Delete a category
    public void deleteCategory(Long id) {
        log.info("Deleting category with id: {}", id);
        if (!categoryRepository.existsById(id)) {
            throw new RuntimeException("Category not found with id: " + id);
        }
        categoryRepository.deleteById(id);
        log.info("Category deleted: {}", id);
    }
}
