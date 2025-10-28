package com.example.watertracker.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MailService {

    private final JavaMailSender mailSender;

    @Value("${custom-mail.mailru.username}")
    private String fromAddress;

    @Value("${app.frontendOrigin:http://localhost:5173}")
    private String frontendOrigin;

    public void sendPasswordReset(String to, String token) {
        String link = frontendOrigin + "/reset-password?token=" + token;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setFrom(fromAddress);  // ✅ важно — совпадает с авторизацией SMTP
        message.setSubject("🔑 Password Reset – WaterTracker");

        message.setText("""
            Здравствуйте!

            Вы запросили сброс пароля для вашего аккаунта WaterTracker.
            Чтобы установить новый пароль, перейдите по ссылке:

            %s

            Если вы не запрашивали это действие, просто проигнорируйте это письмо.

            С уважением,
            Команда WaterTracker 🌊
            """.formatted(link));

        try {
            mailSender.send(message);
            System.out.println("📧 Password reset email sent to " + to);
        } catch (Exception e) {
            System.out.println("❌ Failed to send email: " + e.getMessage());
        }
    }
}
