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

    @Value("${app.frontendOrigin:http://localhost:5173}")
    private String front;

    public void sendPasswordReset(String to, String token) {
        String link = front + "/reset-password?token=" + token;
        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setTo(to);
        msg.setSubject("Password reset");
        msg.setText("Hi!\n\nTo reset your password follow the link:\n" + link + "\n\nIf you didn’t request it – just ignore.");
        mailSender.send(msg);
    }
}
