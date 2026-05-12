package service;

import org.springframework.stereotype.Service;

import service.dto.RecommendationRequest;

@Service
public class PromptService {

    public String buildPrompt(RecommendationRequest req) {

        double bmi = req.weight / Math.pow(req.height / 100, 2);

        return """
        You are a professional nutritionist.

        User:
        - Weight: %.1f kg
        - Height: %.1f cm
        - BMI: %.1f
        - Goal: %s (lose fat or gain muscle)
        - Duration: %d days

        Task:
        Generate a meal plan for each day.

        Rules:
        - Only suggest realistic foods
        - DO NOT invent calories
        - Keep meals simple (breakfast, lunch, dinner)

        Output JSON:
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
                bmi,
                req.goal,
                req.days
        );
    }
}