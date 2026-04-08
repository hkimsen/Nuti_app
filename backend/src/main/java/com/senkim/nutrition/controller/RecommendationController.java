package com.senkim.nutrition.controller;

import com.senkim.nutrition.dto.RecommendationRequest;
import com.senkim.nutrition.service.AiService;
import com.senkim.nutrition.service.PromptService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
@CrossOrigin("*")
public class RecommendationController {

    private final AiService aiService;
    private final PromptService promptService;

    @PostMapping("/recommend")
    public String recommend(@RequestBody RecommendationRequest request) {

        String prompt = promptService.buildPrompt(request);

        return aiService.generateMealPlan(prompt);
    }
}