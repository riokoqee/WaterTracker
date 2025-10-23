package com.example.watertracker.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.List;

public class WaterDTOs {

    @Getter @Setter
    public static class CreateLogRequest {
        @NotNull @Min(10) public Integer amountMl;
        public String note;
        public OffsetDateTime loggedAt;
    }

    @Getter @Setter @AllArgsConstructor @NoArgsConstructor @Builder
    public static class WaterLogResponse {
        public Long id;
        public Integer amountMl;
        public String note;
        public OffsetDateTime loggedAt;
    }

    @Getter @Setter @AllArgsConstructor @NoArgsConstructor @Builder
    public static class WaterStats8Days {
        public List<String> labels;
        public List<Integer> totalsMl;
        public Integer sumMl;
        public Integer targetMl;
    }
}
