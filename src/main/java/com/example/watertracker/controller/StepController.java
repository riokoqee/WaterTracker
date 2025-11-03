package com.example.watertracker.controller;

import com.example.watertracker.service.StepService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/steps")
@RequiredArgsConstructor
public class StepController {

    private final StepService steps;

    @PostMapping("/save")
    public void save(@AuthenticationPrincipal UserDetails user, @RequestBody StepRequest r) {
        steps.saveSteps(user.getUsername(), r.steps);
    }

    @GetMapping("/today")
    public Map<String, Integer> today(@AuthenticationPrincipal UserDetails user) {
        return Map.of("steps", steps.getTodaySteps(user.getUsername()));
    }

    @GetMapping("/week")
    public Map<String, Integer> week(@AuthenticationPrincipal UserDetails user) {
        return steps.getLast7Days(user.getUsername());
    }

    @Data
    public static class StepRequest {
        private int steps;
    }
}
