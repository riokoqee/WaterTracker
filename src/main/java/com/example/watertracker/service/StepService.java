package com.example.watertracker.service;

import com.example.watertracker.model.DailySteps;
import com.example.watertracker.model.User;
import com.example.watertracker.repository.StepLogRepository;
import com.example.watertracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class StepService {

    private final StepLogRepository stepsRepo;
    private final UserRepository users;

    public void saveSteps(String email, int steps) {
        User user = users.findByEmail(email).orElseThrow();
        LocalDate today = LocalDate.now();

        DailySteps log = stepsRepo.findByUserIdAndDate(user.getId(), today);
        if (log == null) {
            log = DailySteps.builder()
                    .user(user)
                    .date(today)
                    .steps(steps)
                    .build();
        } else {
            log.setSteps(steps);
        }
        stepsRepo.save(log);
    }

    public int getTodaySteps(String email) {
        User user = users.findByEmail(email).orElseThrow();
        DailySteps log = stepsRepo.findByUserIdAndDate(user.getId(), LocalDate.now());
        return log == null ? 0 : log.getSteps();
    }

    public Map<String, Integer> getLast7Days(String email) {
        User user = users.findByEmail(email).orElseThrow();
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(6);

        List<DailySteps> logs = stepsRepo.findAllByUserIdAndDateBetween(user.getId(), weekAgo, today);

        Map<String, Integer> result = new LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            result.put(d.toString(), logs.stream()
                    .filter(l -> l.getDate().equals(d))
                    .mapToInt(DailySteps::getSteps)
                    .findFirst().orElse(0));
        }
        return result;
    }
}
