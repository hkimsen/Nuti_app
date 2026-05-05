package service.dto;

import lombok.Data;

@Data
public class HealthRequest {
    private Long userId;
    private double height;
    private double weight;
    private double bmi;
    private String gender;
    private String goal;
}