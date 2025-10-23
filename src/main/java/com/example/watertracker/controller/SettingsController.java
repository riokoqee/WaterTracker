package com.example.watertracker.controller;

import com.example.watertracker.dto.SettingsDTOs.*;
import com.example.watertracker.service.SettingsService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class SettingsController {

    private final SettingsService settings;

    public SettingsController(SettingsService settings) {
        this.settings = settings;
    }

    @GetMapping
    public ResponseEntity<SettingsResponse> get(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(settings.get(user));
    }

    @PutMapping
    public ResponseEntity<SettingsResponse> update(@AuthenticationPrincipal UserDetails user,
                                                   @RequestBody UpdateSettingsRequest req) {
        return ResponseEntity.ok(settings.update(user, req));
    }

    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(@AuthenticationPrincipal UserDetails user,
                                                 @RequestBody ChangePasswordRequest req) {
        return ResponseEntity.ok(settings.changePassword(user, req));
    }

    @DeleteMapping("/reset-data")
    public ResponseEntity<String> reset(@AuthenticationPrincipal UserDetails user) {
        settings.resetData(user);
        return ResponseEntity.ok("Данные профиля успешно очищены");
    }
}
