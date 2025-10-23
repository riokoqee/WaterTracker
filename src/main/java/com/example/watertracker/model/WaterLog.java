package com.example.watertracker.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(indexes = @Index(name = "idx_waterlog_user_time", columnList = "user_id, loggedAt"))
public class WaterLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private User user;

    @Column(nullable = false)
    private Integer amountMl;

    private String note;

    @Column(nullable = false)
    private OffsetDateTime loggedAt;

    @Column(name = "date")
    private LocalDate date;

    @PrePersist
    protected void onCreate() {
        // автоматическая установка значений перед сохранением
        if (loggedAt == null) {
            loggedAt = OffsetDateTime.now();
        }
        if (date == null) {
            date = LocalDate.now();
        }
    }
}
