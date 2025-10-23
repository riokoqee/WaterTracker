package com.example.watertracker.controller;

import com.example.watertracker.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService stats;

    @GetMapping("/daily")
    public Map<String, Object> getDaily(@AuthenticationPrincipal UserDetails user) {
        return stats.getDailyStats(user.getUsername());
    }

    @GetMapping("/weekly")
    public Map<String, Object> getWeekly(@AuthenticationPrincipal UserDetails user) {
        return stats.getWeeklyStats(user.getUsername());
    }
}
