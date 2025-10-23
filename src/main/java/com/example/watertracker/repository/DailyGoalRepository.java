package com.example.watertracker.repository;

import com.example.watertracker.model.DailyGoal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DailyGoalRepository extends JpaRepository<DailyGoal, Long> {
    Optional<DailyGoal> findByUserId(Long userId);
}
