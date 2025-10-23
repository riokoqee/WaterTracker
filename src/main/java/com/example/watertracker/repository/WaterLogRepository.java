package com.example.watertracker.repository;

import com.example.watertracker.model.WaterLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

public interface WaterLogRepository extends JpaRepository<WaterLog, Long> {

    List<WaterLog> findAllByUserIdAndLoggedAtBetweenOrderByLoggedAtAsc(
            Long userId, OffsetDateTime from, OffsetDateTime to
    );

    List<WaterLog> findByUserIdAndDate(Long userId, LocalDate date);
    List<WaterLog> findByUserIdAndDateBetween(Long userId, LocalDate start, LocalDate end);

    // ✅ Исправленный метод подсчёта за сегодня
    @Query("""
        SELECT COALESCE(SUM(w.amountMl), 0)
        FROM WaterLog w
        WHERE w.user.id = :userId
          AND w.loggedAt >= :startOfDay
          AND w.loggedAt < :endOfDay
    """)
    int sumToday(
            @Param("userId") Long userId,
            @Param("startOfDay") OffsetDateTime startOfDay,
            @Param("endOfDay") OffsetDateTime endOfDay
    );
}
