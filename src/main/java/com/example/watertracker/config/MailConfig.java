package com.example.watertracker.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

@Configuration
public class MailConfig {

    private JavaMailSender buildSender(String host, int port, String user, String pass, boolean ssl) {
        JavaMailSenderImpl sender = new JavaMailSenderImpl();
        sender.setHost(host);
        sender.setPort(port);
        sender.setUsername(user);
        sender.setPassword(pass);

        Properties props = sender.getJavaMailProperties();
        props.put("mail.smtp.auth", true);
        props.put("mail.smtp.starttls.enable", !ssl);
        props.put("mail.smtp.ssl.enable", ssl);
        props.put("mail.transport.protocol", "smtp");
        return sender;
    }

    // ✅ теперь Mail.ru — основной, а Gmail — дополнительный
    @Bean("mailruMailSender")
    @Primary
    public JavaMailSender mailruMailSender(
            @Value("${custom-mail.mailru.host}") String host,
            @Value("${custom-mail.mailru.port}") int port,
            @Value("${custom-mail.mailru.username}") String user,
            @Value("${custom-mail.mailru.password}") String pass
    ) {
        return buildSender(host, port, user, pass, true);
    }

    @Bean("gmailMailSender")
    public JavaMailSender gmailMailSender(
            @Value("${custom-mail.gmail.host}") String host,
            @Value("${custom-mail.gmail.port}") int port,
            @Value("${custom-mail.gmail.username}") String user,
            @Value("${custom-mail.gmail.password}") String pass
    ) {
        return buildSender(host, port, user, pass, false);
    }
}
