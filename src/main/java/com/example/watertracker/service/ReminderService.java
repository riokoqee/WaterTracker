package com.example.watertracker.service;

import com.example.watertracker.dto.ReminderDTOs.*;
import com.example.watertracker.model.Reminder;
import com.example.watertracker.model.User;
import com.example.watertracker.repository.ReminderRepository;
import com.example.watertracker.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReminderService {

    private final ReminderRepository reminders;
    private final UserRepository users;

    public ReminderService(ReminderRepository reminders, UserRepository users) {
        this.reminders = reminders;
        this.users = users;
    }

    public List<ReminderResponse> getReminders(org.springframework.security.core.userdetails.UserDetails user) {
        Long uid = users.findByEmail(user.getUsername()).get().getId();
        return reminders.findAllByUserId(uid).stream()
                .map(r -> new ReminderResponse(r.getId(), r.getTime(), r.isActive()))
                .collect(Collectors.toList());
    }

    public ReminderResponse add(org.springframework.security.core.userdetails.UserDetails user, AddReminderRequest req) {
        Long uid = users.findByEmail(user.getUsername()).get().getId();
        User u = users.findById(uid).orElseThrow();
        Reminder r = Reminder.builder()
                .user(u)
                .time(req.getTime())
                .active(true)
                .build();
        reminders.save(r);
        return new ReminderResponse(r.getId(), r.getTime(), r.isActive());
    }

    public ReminderResponse toggle(Long id, boolean active) {
        Reminder r = reminders.findById(id).orElseThrow();
        r.setActive(active);
        reminders.save(r);
        return new ReminderResponse(r.getId(), r.getTime(), r.isActive());
    }
}
