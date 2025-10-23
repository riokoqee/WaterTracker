package com.example.watertracker.dto;

import lombok.*;

public class SettingsDTOs {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SettingsResponse {
        private boolean notificationsEnabled;
        private boolean darkMode;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateSettingsRequest {
        private Boolean notificationsEnabled;
        private Boolean darkMode;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChangePasswordRequest {
        private String oldPassword;
        private String newPassword;
    }
}
