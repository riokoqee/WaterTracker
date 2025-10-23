package com.example.watertracker.controller;

import com.example.watertracker.dto.ProfileDTOs.*;
import com.example.watertracker.model.User;
import com.example.watertracker.service.GoalService;
import com.example.watertracker.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final UserService users;
    private final GoalService goals;

    @GetMapping
    public ProfileResponse me(@AuthenticationPrincipal UserDetails principal) {
        User u = users.findByEmail(principal.getUsername()).orElseThrow();
        var g = goals.getOrDefault(u.getId());
        return ProfileResponse.builder()
                .id(u.getId())
                .firstName(u.getFirstName())
                .lastName(u.getLastName())
                .email(u.getEmail())
                .gender(u.getGender())
                .age(u.getAge())
                .weightKg(u.getWeightKg())
                .heightCm(u.getHeightCm())
                .wakeTime(u.getWakeTime())
                .sleepTime(u.getSleepTime())
                .goalTargetMl(g.getTargetMl())
                .build();
    }

    @PutMapping
    public ProfileResponse update(@AuthenticationPrincipal UserDetails principal,
                                  @RequestBody @Valid UpdateProfileRequest r) {
        User updated = users.updateProfile(users.getByEmail(principal.getUsername()).getId(), u -> {
            u.setFirstName(r.getFirstName());
            u.setLastName(r.getLastName());
            u.setEmail(r.getEmail());
            u.setGender(r.getGender());
            u.setAge(r.getAge());
            u.setWeightKg(r.getWeightKg());
            u.setHeightCm(r.getHeightCm());
            u.setWakeTime(r.getWakeTime());
            u.setSleepTime(r.getSleepTime());
        });
        var g = goals.getOrDefault(updated.getId());
        return ProfileResponse.builder()
                .id(updated.getId())
                .firstName(updated.getFirstName())
                .lastName(updated.getLastName())
                .email(updated.getEmail())
                .gender(updated.getGender())
                .age(updated.getAge())
                .weightKg(updated.getWeightKg())
                .heightCm(updated.getHeightCm())
                .wakeTime(updated.getWakeTime())
                .sleepTime(updated.getSleepTime())
                .goalTargetMl(g.getTargetMl())
                .build();
    }
}
