package com.example.store.repository;

import com.example.store.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // Spring generates:
    // SELECT * FROM users WHERE email = ?
    // Optional because user might not exist
    Optional<User> findByEmail(String email);

    // Spring generates:
    // SELECT COUNT(*) > 0 FROM users WHERE email = ?
    // Used to check if email already registered
    boolean existsByEmail(String email);
}