package com.example.watertracker.service;

import com.example.watertracker.model.DailyStats;
import com.example.watertracker.model.User;
import com.example.watertracker.repository.DailyStatsRepository;
import com.example.watertracker.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class DailyStatsService {

    private final DailyStatsRepository stats;
    private final UserRepository users;

    public DailyStatsService(DailyStatsRepository stats, UserRepository users) {
        this.stats = stats;
        this.users = users;
    }

    public DailyStats getToday(User user) {
        return stats.findByUserIdAndDate(user.getId(), LocalDate.now());
    }

    public void updateSteps(User user, int steps) {
        var s = stats.findByUserIdAndDate(user.getId(), LocalDate.now());
        if (s == null) s = new DailyStats(null, user, LocalDate.now(), steps, 0.0, 0.0);
        else s.setSteps(steps);
        stats.save(s);
    }

    public void updateSleep(User user, double hours) {
        var s = stats.findByUserIdAndDate(user.getId(), LocalDate.now());
        if (s == null) s = new DailyStats(null, user, LocalDate.now(), 0, 0.0, hours);
        else s.setSleepHours(hours);
        stats.save(s);
    }
}
