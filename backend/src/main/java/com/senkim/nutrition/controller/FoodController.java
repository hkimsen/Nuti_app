package com.senkim.nutrition.controller;

import com.senkim.nutrition.entity.Food;
import com.senkim.nutrition.repository.FoodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/foods")
@RequiredArgsConstructor
public class FoodController {

    private final FoodRepository foodRepository;

    @GetMapping
    public List<Food> getFoods() {
        return foodRepository.findAll();
    }
}