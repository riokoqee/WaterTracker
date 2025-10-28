package com.example.watertracker.security;

import com.example.watertracker.service.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Lazy
    private final UserService userService;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String path = request.getServletPath();
        System.out.println("🟡 JwtAuthFilter triggered for: " + path);

        try {
            // ✅ Пропускаем эндпоинты, где токен не требуется
            if ((path.startsWith("/api/auth/") && !path.startsWith("/api/auth/profile"))
                    || path.startsWith("/oauth2/")
                    || path.startsWith("/login/oauth2/")
                    || path.startsWith("/swagger-ui/")
                    || path.startsWith("/v3/api-docs")) {

                System.out.println("🟢 Skipping filter for public endpoint: " + path);
                filterChain.doFilter(request, response);
                return;
            }

            // ✅ Извлекаем заголовок Authorization
            final String authHeader = request.getHeader("Authorization");
            if (authHeader == null) {
                System.out.println("⚠️ Missing Authorization header");
                filterChain.doFilter(request, response);
                return;
            }
            if (!authHeader.startsWith("Bearer ")) {
                System.out.println("⚠️ Authorization header does not start with Bearer");
                filterChain.doFilter(request, response);
                return;
            }

            // ✅ Извлекаем токен и subject
            final String jwt = authHeader.substring(7);
            final String userEmail = jwtUtil.getSubject(jwt);
            System.out.println("🔍 Extracted token subject (email): " + userEmail);

            // ✅ Проверяем, не установлен ли уже контекст
            if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                System.out.println("🔍 Loading user from DB by email: " + userEmail);
                UserDetails userDetails = userService.loadUserByUsername(userEmail);

                System.out.println("🔍 Checking token expiration...");
                boolean expired = jwtUtil.isExpired(jwt);
                System.out.println("   ⏱ Token expired = " + expired);

                if (!expired) {
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);

                    System.out.println("✅ Authentication set for user: " + userEmail);
                    System.out.println("🔎 SecurityContext now: " + SecurityContextHolder.getContext().getAuthentication());
                } else {
                    System.out.println("⚠️ Token expired for user: " + userEmail);
                }
            } else {
                System.out.println("⚠️ userEmail is null OR context already authenticated");
                System.out.println("🔎 SecurityContext before filter end: " + SecurityContextHolder.getContext().getAuthentication());
            }

            filterChain.doFilter(request, response);

        } catch (Exception e) {
            System.out.println("❌ JWT filter exception: " + e.getClass().getSimpleName() + " → " + e.getMessage());
            e.printStackTrace();

            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid or expired token\"}");
        }

        System.out.println("🟣 Filter finished for: " + path);
        System.out.println("───────────────────────────────────────────────");
    }
}
