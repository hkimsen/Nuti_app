package com.senkim.nutrition.service;

import com.senkim.nutrition.dto.RecommendationRequest;
import org.springframework.stereotype.Service;

@Service
public class PromptService {

    public String buildPrompt(RecommendationRequest req) {

        return """
        You are a nutrition expert.

        User info:
        - Weight: %.1f kg
        - Height: %.1f cm
        - BMI: %.1f
        - Goal: %s (gain muscle or lose fat)
        - Duration: %d days

        Task:
        Generate a daily meal plan (breakfast, lunch, dinner).

        IMPORTANT:
        - Only suggest common foods
        - Keep calories realistic
        - Do NOT hallucinate nutrition values
        - Output JSON format:
        [
          {
            "day": 1,
            "meals": [
              {"name": "food name"}
            ]
          }
        ]
        """.formatted(
                req.weight,
                req.height,
                req.bmi,
                req.goal,
                req.days
        );
    }
}