package com.example.watertracker.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DashboardResponse {
    private String greeting;
    private int targetMl;
    private int currentMl;
    private int progress;
    private String lastIntakeTime;
}
