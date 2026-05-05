package com.senkim.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponse {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private Double height;
    private Double weight;
    private Double bmi;
    private String gender;
    private String goal;
}
