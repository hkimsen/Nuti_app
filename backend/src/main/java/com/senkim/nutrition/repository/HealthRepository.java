package com.senkim.nutrition.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.senkim.nutrition.entity.Health;
import java.util.List;
import java.util.Optional;

public interface HealthRepository extends JpaRepository<Health, Long> {
    // user_health historically may contain multiple rows per user; always read the latest
    Optional<Health> findTopByUserIdOrderByIdDesc(Long userId);
    List<Health> findAllByUserIdOrderByIdDesc(Long userId);
}