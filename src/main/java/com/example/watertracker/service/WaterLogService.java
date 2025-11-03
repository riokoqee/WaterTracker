package com.example.watertracker.service;

import com.example.watertracker.model.DailyGoal;
import com.example.watertracker.model.User;
import com.example.watertracker.model.WaterLog;
import com.example.watertracker.repository.UserRepository;
import com.example.watertracker.repository.WaterLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class WaterLogService {
    private final WaterLogRepository repo;

    private final UserRepository users;

    @Transactional
    public WaterLog create(Long userId, Integer amountMl, String note, OffsetDateTime ts) {
        if (ts == null) ts = OffsetDateTime.now();
        WaterLog log = WaterLog.builder()
                .user(com.example.watertracker.model.User.builder().id(userId).build())
                .amountMl(amountMl)
                .note(note)
                .loggedAt(ts)
                .build();
        return repo.save(log);
    }

    public Map<String, Integer> last8DaysTotals(Long userId, ZoneId zone) {
        OffsetDateTime startOfDay = OffsetDateTime.now().toLocalDate().atStartOfDay().atOffset(OffsetDateTime.now().getOffset());
        OffsetDateTime endOfDay = startOfDay.plusDays(1);

        int todayTotal = repo.sumToday(userId, startOfDay, endOfDay);

        OffsetDateTime from = startOfDay.minusDays(7);
        OffsetDateTime end = endOfDay;

        var list = repo.findAllByUserIdAndLoggedAtBetweenOrderByLoggedAtAsc(userId, from, end);
        Map<String, Integer> map = new LinkedHashMap<>();
        DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy-MM-dd").withZone(zone);

        for (int i = 7; i >= 0; i--) {
            OffsetDateTime day = startOfDay.minusDays(i);
            String key = f.format(day);
            int total = list.stream()
                    .filter(l -> l.getLoggedAt().toLocalDate().equals(day.toLocalDate()))
                    .mapToInt(l -> l.getAmountMl() != null ? l.getAmountMl() : 0)
                    .sum();
            map.put(key, total);
        }

        return map;
    }

    public List<WaterLog> getTodayLogs(String email) {
        User user = users.findByEmail(email).orElseThrow();
        LocalDate today = LocalDate.now();
        return repo.findByUserIdAndDate(user.getId(), today);
    }

    public WaterLog addLog(String email, WaterLog log) {
        User user = users.findByEmail(email).orElseThrow();
        log.setUser(user);
        log.setDate(LocalDate.now());
        return repo.save(log);
    }

    public Map<String, Object> drink(String email, int amountMl) {
        User user = users.findByEmail(email).orElseThrow();

        // Записываем лог
        create(user.getId(), amountMl, "glass", OffsetDateTime.now());

        // Возвращаем текущий прогресс за сегодня
        OffsetDateTime start = OffsetDateTime.now().toLocalDate().atStartOfDay().atOffset(OffsetDateTime.now().getOffset());
        OffsetDateTime end = start.plusDays(1);
        int consumed = repo.sumToday(user.getId(), start, end);

        int target = 2000;
        var goal = repoGoal(user.getId()); // небольшой helper ниже
        if (goal != null && goal.getTargetMl() != null) target = goal.getTargetMl();

        return Map.of("consumedMl", consumed, "targetMl", target);
    }

    // helper: вытащить цель (необязательно, но удобно)
    private DailyGoal repoGoal(Long userId) {
        // Лучше инжектнуть DailyGoalRepository в этот сервис,
        // или получить через GoalService (если уже помечен @Service)
        // Простой вариант: через контекст, но рекомендуется именно инжект.
        return null; // закомментируй или переделай, если решишь использовать GoalService в контроллере.
    }
}
