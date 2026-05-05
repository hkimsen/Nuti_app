package com.senkim.nutrition.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.senkim.nutrition.entity.Meal;
import com.senkim.nutrition.repository.MealRepository;
import service.dto.MealRequest;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/meals")
@CrossOrigin
public class MealController {

    private final MealRepository mealRepository;

    public MealController(MealRepository mealRepository) {
        this.mealRepository = mealRepository;
    }

    @PostMapping
    public ResponseEntity<?> addMeal(@RequestBody MealRequest req) {
        System.out.println("DEBUG: Adding meal - userId=" + req.getUserId() + 
            ", foodName=" + req.getFoodName() + 
            ", mealType=" + req.getMealType());

        Meal meal = new Meal();
        meal.setUserId(req.getUserId());
        meal.setFoodId(req.getFoodId());
        meal.setFoodName(req.getFoodName());
        meal.setMealType(req.getMealType());
        meal.setGram(req.getGram());
        meal.setCalories(req.getCalories());
        meal.setProtein(req.getProtein());
        meal.setCarbs(req.getCarbs());
        meal.setFat(req.getFat());
        meal.setDate(req.getDate() != null ? req.getDate() : LocalDate.now());

        Meal saved = mealRepository.save(meal);
        System.out.println("DEBUG: Meal saved with id=" + saved.getId());

        return ResponseEntity.ok(saved);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserMeals(
            @PathVariable Long userId,
            @RequestParam(required = false) String date) {

        System.out.println("DEBUG: Getting meals for userId=" + userId + ", date=" + date);

        LocalDate targetDate = date != null ? LocalDate.parse(date) : LocalDate.now();
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, targetDate);

        System.out.println("DEBUG: Found " + meals.size() + " meals");

        return ResponseEntity.ok(meals);
    }
}
