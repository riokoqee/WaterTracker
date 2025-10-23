package com.example.watertracker.controller;

import com.example.watertracker.service.AuthService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService auth;

    @PostMapping("/register")
    public ResponseEntity<AuthService.Tokens> register(@RequestBody RegisterRequest r) {
        return ResponseEntity.ok(auth.register(r.firstName, r.lastName, r.email, r.password));
    }

    @Data
    public static class RegisterRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String password;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthService.Tokens> login(@RequestBody LoginRequest r) {
        return ResponseEntity.ok(auth.login(r.email, r.password));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthService.Tokens> refresh(@RequestHeader("Authorization") String bearer) {
        String token = bearer != null && bearer.startsWith("Bearer ") ? bearer.substring(7) : bearer;
        return ResponseEntity.ok(auth.refresh(token));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgot(@RequestBody EmailRequest r) {
        auth.startPasswordReset(r.email);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> reset(@RequestBody ResetRequest r) {
        auth.finishPasswordReset(r.token, r.newPassword);
        return ResponseEntity.ok().build();
    }

    @Data public static class LoginRequest { public String email; public String password; }
    @Data public static class EmailRequest { public String email; }
    @Data public static class ResetRequest { public String token; public String newPassword; }
}
