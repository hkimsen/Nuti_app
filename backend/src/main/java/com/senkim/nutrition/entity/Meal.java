package com.senkim.nutrition.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "meals")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Long foodId;
    private String foodName;
    private String mealType; // breakfast, lunch, dinner

    private double gram;
    private double calories;
    private double protein;
    private double carbs;
    private double fat;

    private LocalDate date;
}
