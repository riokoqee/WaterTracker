package com.example.watertracker.service;

import com.example.watertracker.dto.SettingsDTOs.*;
import com.example.watertracker.model.User;
import com.example.watertracker.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class SettingsService {

    private final UserRepository users;
    private final PasswordEncoder encoder;

    public SettingsService(UserRepository users, PasswordEncoder encoder) {
        this.users = users;
        this.encoder = encoder;
    }

    public SettingsResponse get(org.springframework.security.core.userdetails.UserDetails user) {
        User u = users.findByEmail(user.getUsername()).orElseThrow();
        return new SettingsResponse(u.isNotificationsEnabled(), u.isDarkMode());
    }

    public SettingsResponse update(org.springframework.security.core.userdetails.UserDetails user,
                                   UpdateSettingsRequest req) {
        User u = users.findByEmail(user.getUsername()).orElseThrow();
        if (req.getNotificationsEnabled() != null) u.setNotificationsEnabled(req.getNotificationsEnabled());
        if (req.getDarkMode() != null) u.setDarkMode(req.getDarkMode());
        users.save(u);
        return new SettingsResponse(u.isNotificationsEnabled(), u.isDarkMode());
    }

    public String changePassword(org.springframework.security.core.userdetails.UserDetails user,
                                 ChangePasswordRequest req) {
        User u = users.findByEmail(user.getUsername()).orElseThrow();

        if (!encoder.matches(req.getOldPassword(), u.getPasswordHash())) {
            throw new IllegalArgumentException("Неверный текущий пароль");
        }

        u.setPasswordHash(encoder.encode(req.getNewPassword()));
        users.save(u);
        return "Пароль успешно изменён";
    }

    public void resetData(org.springframework.security.core.userdetails.UserDetails user) {
        User u = users.findByEmail(user.getUsername()).orElseThrow();
        u.setWeightKg(null);
        u.setHeightCm(null);
        u.setAge(null);
        users.save(u);
    }
}
