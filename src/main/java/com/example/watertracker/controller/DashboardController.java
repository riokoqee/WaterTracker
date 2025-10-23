package com.example.watertracker.controller;

import com.example.watertracker.dto.DashboardResponse;
import com.example.watertracker.service.DashboardService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    private final DashboardService dashboard;

    public DashboardController(DashboardService dashboard) {
        this.dashboard = dashboard;
    }

    @GetMapping
    public ResponseEntity<DashboardResponse> get(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(dashboard.get(user));
    }
}
