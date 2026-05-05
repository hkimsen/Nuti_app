package com.senkim.nutrition.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_health")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Health {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private double height;
    private double weight;
    private double bmi;

    private String gender;
    private String goal;
}