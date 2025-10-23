package com.example.watertracker.controller;

import com.example.watertracker.dto.ReminderDTOs.*;
import com.example.watertracker.service.ReminderService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reminders")
@CrossOrigin(origins = "*")
public class ReminderController {

    private final ReminderService service;

    public ReminderController(ReminderService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<ReminderResponse>> get(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(service.getReminders(user));
    }

    @PostMapping
    public ResponseEntity<ReminderResponse> add(@AuthenticationPrincipal UserDetails user,
                                                @RequestBody AddReminderRequest req) {
        return ResponseEntity.ok(service.add(user, req));
    }

    @PatchMapping("/{id}/toggle")
    public ResponseEntity<ReminderResponse> toggle(@PathVariable Long id, @RequestParam boolean active) {
        return ResponseEntity.ok(service.toggle(id, active));
    }
}
