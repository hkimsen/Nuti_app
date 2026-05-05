package com.senkim.nutrition.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.senkim.nutrition.service.AiService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin
public class RecommendationController {

    private final AiService aiService;
    private final ObjectMapper mapper = new ObjectMapper();

    public RecommendationController(AiService aiService) {
        this.aiService = aiService;
    }

    @PostMapping("/recommend")
    public Object recommend(@RequestBody Map<String, Object> req) {

        try {
            System.out.println("Recommend endpoint called with: " + req);
            
            // ===== CALL AI =====
            JsonNode aiResult = aiService.generateMealPlan(req);

            if (aiResult == null) {
                System.out.println("AI returned null");
                return Map.of(
                        "error", "AI returned null"
                );
            }

            System.out.println("AI Result: " + aiResult.toPrettyString());
            
            // ===== RETURN ALL FIELDS FROM AI RESULT =====
            // The service already includes: bmi, tdee, dailyCalories, plan
            return mapper.convertValue(aiResult, Map.class);

        } catch (Exception e) {
            System.out.println("Error in recommend: " + e.getMessage());
            e.printStackTrace();
            return Map.of(
                    "error", "Failed to generate recommendation",
                    "message", e.getMessage()
            );
        }
    }
}