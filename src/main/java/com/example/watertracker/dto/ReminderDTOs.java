package com.example.watertracker.dto;

import lombok.*;
import java.time.LocalTime;

public class ReminderDTOs {

    @Getter
    @Setter
    public static class AddReminderRequest {
        private LocalTime time;
    }

    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class ReminderResponse {
        private Long id;
        private LocalTime time;
        private boolean active;
    }
}
