package com.senkim.nutrition.repository;

import com.senkim.nutrition.entity.WeightLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface WeightLogRepository extends JpaRepository<WeightLog, Long> {
    Optional<WeightLog> findTopByUserIdAndDateOrderByIdDesc(Long userId, LocalDate date);
    List<WeightLog> findByUserIdAndDateBetweenOrderByDateAscIdAsc(Long userId, LocalDate from, LocalDate to);
}
