package com.example.watertracker.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalTime;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    private Gender gender;

    private Integer age;
    private Double weightKg;
    private Double heightCm;

    private LocalTime wakeTime;
    private LocalTime sleepTime;

    @ElementCollection(fetch = FetchType.EAGER)
    @Enumerated(EnumType.STRING)
    private Set<Role> roles;

    private String resetToken;
    private java.time.Instant resetTokenExpiry;

    private boolean notificationsEnabled = true;
    private boolean darkMode = false;
}
