package com.example.watertracker.dto;

import jakarta.validation.constraints.*;
import lombok.*;

public class GoalDTOs {

    @Getter @Setter
    public static class UpsertGoalRequest {
        @NotNull @Min(500) @Max(10000) public Integer targetMl;
        public Boolean remindersEnabled = false;
        public Integer reminderEveryMin = 60;
    }

    @Getter @Setter @AllArgsConstructor @NoArgsConstructor @Builder
    public static class GoalResponse {
        public Integer targetMl;
        public Boolean remindersEnabled;
        public Integer reminderEveryMin;
    }
}
