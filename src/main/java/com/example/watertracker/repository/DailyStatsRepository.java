package com.example.watertracker.repository;

import com.example.watertracker.model.DailyStats;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface DailyStatsRepository extends JpaRepository<DailyStats, Long> {
    List<DailyStats> findAllByUserIdAndDateAfter(Long userId, LocalDate date);
    DailyStats findByUserIdAndDate(Long userId, LocalDate date);
}
