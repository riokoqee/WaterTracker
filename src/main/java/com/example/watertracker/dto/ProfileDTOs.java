package com.example.watertracker.dto;

import com.example.watertracker.model.Gender;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalTime;

public class ProfileDTOs {

    @Getter @Setter
    public static class UpdateProfileRequest {
        @NotBlank public String firstName;
        @NotBlank public String lastName;
        @Email @NotBlank public String email;

        public Gender gender;
        @Min(0) @Max(120) public Integer age;
        @PositiveOrZero public Double weightKg;
        @PositiveOrZero public Double heightCm;

        public LocalTime wakeTime;
        public LocalTime sleepTime;
    }

    @Getter @Setter @AllArgsConstructor @NoArgsConstructor @Builder
    public static class ProfileResponse {
        public Long id;
        public String firstName, lastName, email;
        public Gender gender;
        public Integer age;
        public Double weightKg, heightCm;
        public LocalTime wakeTime, sleepTime;
        public Integer goalTargetMl;
    }
}
