package com.example.watertracker.service;

import com.example.watertracker.model.User;
import com.example.watertracker.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authManager;
    private final JwtUtil jwt;
    private final UserService users;
    private final MailService mailService;

    public Tokens register(String firstName, String lastName, String email, String password) {
        users.register(firstName, lastName, email, password);
        return issueTokens(email);
    }

    public Tokens login(String email, String password) {
        Authentication auth = authManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, password));
        log.info("✅ Login success for {}", email);
        return issueTokens(email);
    }

    public Tokens issueTokens(String email) {
        String access = jwt.generateAccess(email, Map.of());
        String refresh = jwt.generateRefresh(email, Map.of());
        return new Tokens(access, refresh);
    }

    public Tokens refresh(String refreshToken) {
        if (!"refresh".equalsIgnoreCase(jwt.getType(refreshToken))) {
            throw new IllegalArgumentException("Not a refresh token");
        }
        String email = jwt.getSubject(refreshToken);
        return issueTokens(email);
    }

    // --- восстановление пароля ---
    public void startPasswordReset(String email) {
        User u = users.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("User not found"));
        String token = UUID.randomUUID().toString();
        users.setResetToken(u, token, Instant.now().plusSeconds(60 * 30));
        mailService.sendPasswordReset(u.getEmail(), token);
        log.info("📨 Reset email sent to {}", email);
    }

    public void finishPasswordReset(String token, String newPassword) {
        User u = users.findByResetToken(token).orElseThrow(() -> new IllegalArgumentException("Invalid token"));
        if (u.getResetTokenExpiry() == null || u.getResetTokenExpiry().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Token expired");
        }
        users.setPassword(u, newPassword);
        users.setResetToken(u, null, null);
        log.info("🔑 Password changed for {}", u.getEmail());
    }

    public record Tokens(String accessToken, String refreshToken) {}
}
