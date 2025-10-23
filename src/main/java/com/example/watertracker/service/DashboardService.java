package com.example.watertracker.service;

import com.example.watertracker.dto.DashboardResponse;
import com.example.watertracker.model.User;
import com.example.watertracker.model.DailyGoal;
import com.example.watertracker.repository.*;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.time.OffsetDateTime;

@Service
public class DashboardService {

    private final UserRepository users;
    private final WaterLogRepository logs;
    private final DailyGoalRepository goals;

    public DashboardService(UserRepository users, WaterLogRepository logs, DailyGoalRepository goals) {
        this.users = users;
        this.logs = logs;
        this.goals = goals;
    }

    public DashboardResponse get(org.springframework.security.core.userdetails.UserDetails user) {
        User u = users.findByEmail(user.getUsername()).orElseThrow();

        DailyGoal goal = goals.findByUserId(u.getId()).orElse(null);
        int target = (goal != null && goal.getTargetMl() != null) ? goal.getTargetMl() : 2000;

        OffsetDateTime startOfDay = OffsetDateTime.now().toLocalDate().atStartOfDay().atOffset(OffsetDateTime.now().getOffset());
        OffsetDateTime endOfDay = startOfDay.plusDays(1);
        int current = logs.sumToday(u.getId(), startOfDay, endOfDay);
        int progress = (int) ((current * 100.0) / target);
        String greeting = "Good Morning, " + u.getFirstName() + " " + u.getLastName();

        return DashboardResponse.builder()
                .greeting(greeting)
                .targetMl(target)
                .currentMl(current)
                .progress(progress)
                .lastIntakeTime(LocalTime.now().minusMinutes(30).toString())
                .build();
    }
}
