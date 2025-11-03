package com.example.watertracker.controller;

import com.example.watertracker.model.DailyGoal;
import com.example.watertracker.service.GoalService;
import com.example.watertracker.service.UserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goal")
@RequiredArgsConstructor
public class GoalController {

    private final GoalService goals;
    private final UserService users;

    @GetMapping
    public ResponseEntity<GoalResponse> get(@AuthenticationPrincipal UserDetails p) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        DailyGoal g = goals.getOrDefault(uid);
        return ResponseEntity.ok(new GoalResponse(g.getTargetMl(), g.getRemindersEnabled(), g.getReminderEveryMin()));
    }

    @PutMapping
    public ResponseEntity<GoalResponse> upsert(@AuthenticationPrincipal UserDetails p,
                                               @RequestBody UpsertGoalRequest r) {
        Long uid = users.getByEmail(p.getUsername()).getId();
        DailyGoal g = goals.upsert(uid, r.targetMl, r.remindersEnabled, r.reminderEveryMin);
        return ResponseEntity.ok(new GoalResponse(g.getTargetMl(), g.getRemindersEnabled(), g.getReminderEveryMin()));
    }

    @Data public static class UpsertGoalRequest {
        public Integer targetMl;          // 2000 и т.п.
        public Boolean remindersEnabled;  // true/false
        public Integer reminderEveryMin;  // 60 и т.п.
    }

    @Data public static class GoalResponse {
        public final Integer targetMl;
        public final Boolean remindersEnabled;
        public final Integer reminderEveryMin;
    }
}
