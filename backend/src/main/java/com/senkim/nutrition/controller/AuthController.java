package com.senkim.nutrition.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.senkim.nutrition.entity.User;
import com.senkim.nutrition.entity.Health;
import com.senkim.nutrition.repository.UserRepository;
import com.senkim.nutrition.repository.HealthRepository;
import com.senkim.nutrition.dto.SignupRequest;
import com.senkim.nutrition.dto.LoginRequest;
import com.senkim.nutrition.dto.LoginResponse;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    private final UserRepository userRepository;
    private final HealthRepository healthRepository;

    public AuthController(UserRepository userRepository, HealthRepository healthRepository) {
        this.userRepository = userRepository;
        this.healthRepository = healthRepository;
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest req) {
        // Check if email already exists
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email already exists");
        }

        User user = new User();
        user.setFirstName(req.getFirstName());
        user.setLastName(req.getLastName());
        user.setEmail(req.getEmail());
        user.setPassword(req.getPassword()); // In production, hash this!

        User savedUser = userRepository.save(user);

        return ResponseEntity.ok(new LoginResponse(
            savedUser.getId(),
            savedUser.getFirstName(),
            savedUser.getLastName(),
            savedUser.getEmail(),
            savedUser.getPhone(),
            null,
            null,
            null,
            null,
            null
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        Optional<User> userOpt = userRepository.findByEmail(req.getEmail());

        if (!userOpt.isPresent()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        User user = userOpt.get();

        // Check password (In production, compare hashes!)
        if (!user.getPassword().equals(req.getPassword())) {
            return ResponseEntity.badRequest().body("Invalid password");
        }

        // Load health info if exists
        Optional<Health> healthOpt = healthRepository.findTopByUserIdOrderByIdDesc(user.getId());
        Double height = null;
        Double weight = null;
        Double bmi = null;
        String gender = null;
        String goal = null;

        if (healthOpt.isPresent()) {
            Health health = healthOpt.get();
            height = health.getHeight();
            weight = health.getWeight();
            bmi = health.getBmi();
            gender = health.getGender();
            goal = health.getGoal();
        }

        return ResponseEntity.ok(new LoginResponse(
            user.getId(),
            user.getFirstName(),
            user.getLastName(),
            user.getEmail(),
            user.getPhone(),
            height,
            weight,
            bmi,
            gender,
            goal
        ));
    }
}
