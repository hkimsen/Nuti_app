package com.senkim.nutrition.controller;

import com.senkim.nutrition.entity.WeightLog;
import com.senkim.nutrition.repository.WeightLogRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import service.dto.WeightLogRequest;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/weights")
@CrossOrigin
public class WeightLogController {

    private final WeightLogRepository weightLogRepository;

    public WeightLogController(WeightLogRepository weightLogRepository) {
        this.weightLogRepository = weightLogRepository;
    }

    @PostMapping
    public ResponseEntity<?> saveDailyWeight(@RequestBody WeightLogRequest req) {
        LocalDate targetDate = req.getDate() != null ? req.getDate() : LocalDate.now();

        WeightLog log = weightLogRepository
                .findTopByUserIdAndDateOrderByIdDesc(req.getUserId(), targetDate)
                .orElseGet(WeightLog::new);

        log.setUserId(req.getUserId());
        log.setWeight(req.getWeight());
        log.setDate(targetDate);

        WeightLog saved = weightLogRepository.save(log);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getWeightHistory(
            @PathVariable Long userId,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to) {
        LocalDate toDate = to != null ? LocalDate.parse(to) : LocalDate.now();
        LocalDate fromDate = from != null ? LocalDate.parse(from) : toDate.minusDays(29);

        List<WeightLog> logs = weightLogRepository.findByUserIdAndDateBetweenOrderByDateAscIdAsc(
                userId,
                fromDate,
                toDate
        );
        return ResponseEntity.ok(logs);
    }
}
