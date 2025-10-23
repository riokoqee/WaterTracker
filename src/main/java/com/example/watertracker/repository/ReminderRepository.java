package com.example.watertracker.repository;

import com.example.watertracker.model.Reminder;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReminderRepository extends JpaRepository<Reminder, Long> {
    List<Reminder> findAllByUserId(Long userId);
}
