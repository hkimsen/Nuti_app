package com.senkim.nutrition.dto;

public class RecommendationRequest {
    public double weight;
    public double height;
    public double bmi;
    public String goal; // "gain" | "lose"
    public int days;
}