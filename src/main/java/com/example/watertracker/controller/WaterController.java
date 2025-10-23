package com.example.watertracker.controller;

import com.example.watertracker.dto.WaterDTOs.*;
import com.example.watertracker.model.WaterLog;
import com.example.watertracker.service.GoalService;
import com.example.watertracker.service.UserService;
import com.example.watertracker.service.WaterLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.ZoneId;
import java.util.ArrayList;

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
}
