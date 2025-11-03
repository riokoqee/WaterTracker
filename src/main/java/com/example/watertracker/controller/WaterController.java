package com.example.watertracker.controller;

import com.example.watertracker.dto.WaterDTOs.*;
import com.example.watertracker.model.WaterLog;
import com.example.watertracker.service.GoalService;
import com.example.watertracker.service.UserService;
import com.example.watertracker.service.WaterLogService;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Map;

@RestController
@RequestMapping("/api/water")
@RequiredArgsConstructor
public class WaterController {

    private final WaterLogService water;
    private final UserService users;
    private final GoalService goals;

    @PostMapping("/logs")
    public WaterLogResponse add(@AuthenticationPrincipal UserDetails p,
                                @RequestBody @Valid CreateLogRequest r) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        WaterLog log = water.create(uid, r.getAmountMl(), r.getNote(), r.getLoggedAt());
        return new WaterLogResponse(log.getId(), log.getAmountMl(), log.getNote(), log.getLoggedAt());
    }

    @GetMapping("/stats/8-days")
    public WaterStats8Days stats(@AuthenticationPrincipal UserDetails p,
                                 @RequestParam(defaultValue = "UTC") String tz) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        var map = water.last8DaysTotals(uid, ZoneId.of(tz));
        var labels = new ArrayList<>(map.keySet());
        var totals = labels.stream().map(map::get).toList();
        int sum = totals.stream().mapToInt(Integer::intValue).sum();
        int target = goals.getOrDefault(uid).getTargetMl();
        return WaterStats8Days.builder()
                .labels(labels)
                .totalsMl(totals)
                .sumMl(sum)
                .targetMl(target)
                .build();
    }

    @GetMapping("/progress/today")
    public TodayProgressResponse today(@AuthenticationPrincipal UserDetails p) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        var goal = goals.getOrDefault(uid);

        // Сумма за сегодня
        OffsetDateTime start = OffsetDateTime.now().toLocalDate().atStartOfDay().atOffset(OffsetDateTime.now().getOffset());
        OffsetDateTime end = start.plusDays(1);
        int consumed = water
                .last8DaysTotals(uid, ZoneId.systemDefault())
                .entrySet()
                .stream()
                .filter(e -> e.getKey().equals(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))))
                .mapToInt(Map.Entry::getValue)
                .findFirst().orElse(0);

        // Лучше: отдельный метод repo.sumToday уже есть → можешь заменить подсчёт на repo.sumToday.
        return new TodayProgressResponse(consumed, goal.getTargetMl());
    }

    // ---- NEW: выпить стакан (или ml) ----
    @PostMapping("/drink")
    public TodayProgressResponse drink(@AuthenticationPrincipal UserDetails p,
                                       @RequestBody DrinkRequest r) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        // пишем лог
        water.create(uid, r.amountMl(), r.note(), OffsetDateTime.now());

        // считаем за сегодня (через sumToday удобнее — он у тебя есть в репозитории)
        OffsetDateTime start = OffsetDateTime.now().toLocalDate().atStartOfDay().atOffset(OffsetDateTime.now().getOffset());
        OffsetDateTime end = start.plusDays(1);
        int consumed = water
                .getTodayLogs(p.getUsername())
                .stream().mapToInt(WaterLog::getAmountMl).sum();

        int target = goals.getOrDefault(uid).getTargetMl();
        return new TodayProgressResponse(consumed, target);
    }

    // --- DTOs ---
    @Data
    public static class CreateLogRequest {
        private Integer amountMl;
        private String note;
        private OffsetDateTime loggedAt;
    }

    public record DrinkRequest(Integer amountMl, String note) {}
    public record WaterLogResponse(Long id, Integer amountMl, String note, OffsetDateTime loggedAt) {}
    public record TodayProgressResponse(Integer consumedMl, Integer targetMl) {}
}
