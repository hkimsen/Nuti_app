package com.senkim.nutrition.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.senkim.nutrition.entity.Health;
import com.senkim.nutrition.entity.User;
import com.senkim.nutrition.repository.HealthRepository;
import com.senkim.nutrition.repository.UserRepository;
import service.dto.HealthRequest;
import service.dto.UserRequest;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
@CrossOrigin
public class UserHealthController {

    private final HealthRepository healthRepository;
    private final UserRepository userRepository;

    public UserHealthController(HealthRepository healthRepository, UserRepository userRepository) {
        this.healthRepository = healthRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getUserData(@PathVariable Long userId) {
        System.out.println("DEBUG: Getting user data for userId=" + userId);

        var userOpt = userRepository.findById(userId);
        if (!userOpt.isPresent()) {
            return ResponseEntity.badRequest().body("User not found");
        }

        User user = userOpt.get();
        var healthOpt = healthRepository.findTopByUserIdOrderByIdDesc(userId);

        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("firstName", user.getFirstName());
        response.put("lastName", user.getLastName());
        response.put("email", user.getEmail());
        response.put("phone", user.getPhone());

        if (healthOpt.isPresent()) {
            Health health = healthOpt.get();
            response.put("height", health.getHeight());
            response.put("weight", health.getWeight());
            response.put("bmi", health.getBmi());
            response.put("gender", health.getGender());
            response.put("goal", health.getGoal());
        }

        System.out.println("DEBUG: Returning user data");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/health")
    public ResponseEntity<?> saveHealth(@RequestBody HealthRequest req) {
        Health h = healthRepository
                .findTopByUserIdOrderByIdDesc(req.getUserId())
                .orElseGet(Health::new);

        h.setUserId(req.getUserId());
        h.setHeight(req.getHeight());
        h.setWeight(req.getWeight());
        h.setBmi(req.getBmi());
        h.setGender(req.getGender());
        h.setGoal(req.getGoal());

        healthRepository.save(h);

        return ResponseEntity.ok("Saved to DB");
    }

    @PostMapping("/account")
    public ResponseEntity<?> saveAccount(@RequestBody UserRequest req) {

        System.out.println("DEBUG: saveAccount called with userId=" + req.getUserId() + 
            ", firstName=" + req.getFirstName() + 
            ", email=" + req.getEmail());

        User u;
        
        // If userId is provided, update existing user
        if (req.getUserId() != null) {
            var userOpt = userRepository.findById(req.getUserId());
            
            if (userOpt.isPresent()) {
                u = userOpt.get();
                System.out.println("DEBUG: Found existing user with id=" + u.getId() + ", current firstName=" + u.getFirstName());
            } else {
                System.out.println("DEBUG: User not found with userId=" + req.getUserId() + ". Creating new.");
                u = new User();
            }
        } else {
            System.out.println("DEBUG: No userId provided. Creating new user.");
            u = new User();
        }
        
        // Update fields - preserve password if not explicitly provided
        u.setFirstName(req.getFirstName());
        u.setLastName(req.getLastName());
        u.setEmail(req.getEmail());
        u.setPhone(req.getPhone());

        User savedUser = userRepository.save(u);
        System.out.println("DEBUG: User saved with id=" + savedUser.getId() + ", firstName=" + savedUser.getFirstName());

        return ResponseEntity.ok("User saved successfully with id=" + savedUser.getId() + ", firstName=" + savedUser.getFirstName());
    }
}