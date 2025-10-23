package com.example.watertracker.security;

import com.example.watertracker.service.AuthService;
import com.example.watertracker.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import org.springframework.context.annotation.Lazy;


@Slf4j
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final UserService users;

    @Lazy
    private final AuthService auth;

    @Value("${app.oauth2.redirectUri}")
    private String redirectUri;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException {

        OAuth2User oauthUser = (OAuth2User) authentication.getPrincipal();
        String email = oauthUser.getAttribute("email");
        String given = oauthUser.getAttribute("given_name");
        String family = oauthUser.getAttribute("family_name");

        // если юзер ещё не зарегистрирован — регистрируем
        users.findByEmail(email).orElseGet(() ->
                users.register(given != null ? given : "User",
                        family != null ? family : "",
                        email,
                        UUID.randomUUID().toString())
        );

        var tokens = auth.issueTokens(email);

        // редирект на фронт (в URL передаём токены)
        String target = UriComponentsBuilder.fromUriString(redirectUri)
                .fragment("access=" + tokens.accessToken() + "&refresh=" + tokens.refreshToken())
                .build(true)
                .toUriString();

        log.info("✅ Google login success for {}", email);
        response.sendRedirect(target);
    }
}
