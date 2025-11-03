package com.example.watertracker.service;

import com.example.watertracker.model.DailyStats;
import com.example.watertracker.model.User;
import com.example.watertracker.model.WaterLog;
import com.example.watertracker.repository.UserRepository;
import com.example.watertracker.repository.WaterLogRepository;
import com.example.watertracker.repository.DailyStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
public class StatsService {

    private final UserRepository users;
    private final WaterLogRepository logs;
    private final DailyStatsRepository statsRepo;

    public Map<String, Object> getDailyStats(String email) {
        User user = users.findByEmail(email).orElseThrow();
        var todayLogs = logs.findByUserIdAndDate(user.getId(), LocalDate.now());
        int totalMl = todayLogs.stream().mapToInt(WaterLog::getAmountMl).sum();

        return Map.of(
                "date", LocalDate.now(),
                "totalMl", totalMl,
                "entries", todayLogs.size()
        );
    }

    public Map<String, Object> getWeeklyStats(String email) {
        User user = users.findByEmail(email).orElseThrow();
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minus(7, ChronoUnit.DAYS);

        var weekLogs = logs.findByUserIdAndDateBetween(user.getId(), weekAgo, today);
        int totalMl = weekLogs.stream().mapToInt(WaterLog::getAmountMl).sum();

        return Map.of(
                "weekStart", weekAgo,
                "weekEnd", today,
                "totalMl", totalMl,
                "entries", weekLogs.size()
        );
    }

    public void saveSteps(String email, int steps) {
        User user = users.findByEmail(email).orElseThrow();
        var today = statsRepo.findByUserIdAndDate(user.getId(), LocalDate.now());

        if (today == null) {
            today = DailyStats.builder()
                    .user(user)
                    .date(LocalDate.now())
                    .steps(steps)
                    .calories(0.0)
                    .sleepHours(0.0)
                    .build();
        } else {
            today.setSteps(steps);
        }

        statsRepo.save(today);
    }

}
