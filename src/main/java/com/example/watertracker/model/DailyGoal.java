package com.example.watertracker.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyGoal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    private User user;

    @Column(nullable = false)
    private Integer targetMl;

    private Boolean remindersEnabled;
    private Integer reminderEveryMin;
}
