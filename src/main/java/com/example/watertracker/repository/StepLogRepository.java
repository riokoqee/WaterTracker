package com.example.watertracker.repository;

import com.example.watertracker.model.DailySteps;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface StepLogRepository extends JpaRepository<DailySteps, Long> {
    DailySteps findByUserIdAndDate(Long userId, LocalDate date);
    List<DailySteps> findAllByUserIdAndDateBetween(Long userId, LocalDate from, LocalDate to);
}
