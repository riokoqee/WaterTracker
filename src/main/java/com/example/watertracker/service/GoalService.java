package com.example.watertracker.service;

import com.example.watertracker.model.DailyGoal;
import com.example.watertracker.repository.DailyGoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final DailyGoalRepository repo;

    public DailyGoal getOrDefault(Long userId) {
        return repo.findByUserId(userId)
                .orElse(DailyGoal.builder()
                        .user(com.example.watertracker.model.User.builder().id(userId).build())
                        .targetMl(2000).remindersEnabled(false).reminderEveryMin(60)
                        .build());
    }

    @Transactional
    public DailyGoal upsert(Long userId, Integer targetMl, Boolean enabled, Integer everyMin) {
        DailyGoal g = repo.findByUserId(userId).orElseGet(
                () -> DailyGoal.builder().user(com.example.watertracker.model.User.builder().id(userId).build()).build()
        );
        g.setTargetMl(targetMl);
        g.setRemindersEnabled(enabled);
        g.setReminderEveryMin(everyMin);
        return repo.save(g);
    }
}
