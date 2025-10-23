package com.example.watertracker.controller;

import com.example.watertracker.model.WaterLog;
import com.example.watertracker.service.WaterLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/water-logs")
@RequiredArgsConstructor
public class WaterLogController {

    private final WaterLogService waterLogs;

    @GetMapping
    public List<WaterLog> getLogs(@AuthenticationPrincipal UserDetails user) {
        return waterLogs.getTodayLogs(user.getUsername());
    }

    @PostMapping
    public WaterLog addLog(@AuthenticationPrincipal UserDetails user,
                           @RequestBody WaterLog log) {
        return waterLogs.addLog(user.getUsername(), log);
    }
}
