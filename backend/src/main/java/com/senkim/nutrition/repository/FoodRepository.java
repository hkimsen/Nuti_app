package com.senkim.nutrition.repository;

import com.senkim.nutrition.entity.Food;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FoodRepository extends JpaRepository<Food, Long> {
}