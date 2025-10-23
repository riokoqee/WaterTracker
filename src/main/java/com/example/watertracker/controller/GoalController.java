package com.example.watertracker.controller;

import com.example.watertracker.dto.GoalDTOs.*;
import com.example.watertracker.service.GoalService;
import com.example.watertracker.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
public class GoalController {

    private final GoalService goals;
    private final UserService users;

    @GetMapping
    public GoalResponse get(@AuthenticationPrincipal UserDetails p) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        var g = goals.getOrDefault(uid);
        return new GoalResponse(g.getTargetMl(), g.getRemindersEnabled(), g.getReminderEveryMin());
    }

    @PostMapping
    public GoalResponse upsert(@AuthenticationPrincipal UserDetails p,
                               @RequestBody UpsertGoalRequest r) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        var g = goals.upsert(uid, r.getTargetMl(), r.getRemindersEnabled(), r.getReminderEveryMin());
        return new GoalResponse(g.getTargetMl(), g.getRemindersEnabled(), g.getReminderEveryMin());
    }
}
