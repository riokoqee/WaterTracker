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
        System.out.println("🟡 JwtAuthFilter triggered for: " + path); // ⬅️ перемещено в начало

        try {
            // ✅ Пропускаем эндпоинты, где токен не требуется
            if (path.startsWith("/api/auth/") ||
                    path.startsWith("/oauth2/") ||
                    path.startsWith("/login/oauth2/") ||
                    path.startsWith("/swagger-ui/") ||
                    path.startsWith("/v3/api-docs")) {

                filterChain.doFilter(request, response);
                return;
            }

            // ✅ Извлекаем заголовок Authorization
            final String authHeader = request.getHeader("Authorization");

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                filterChain.doFilter(request, response);
                return;
            }

            // ✅ Извлекаем сам токен (без Bearer)
            final String jwt = authHeader.substring(7);
            final String userEmail = jwtUtil.getSubject(jwt);

            if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = userService.loadUserByUsername(userEmail);

                if (!jwtUtil.isExpired(jwt)) {
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);

                    System.out.println("✅ Authenticated via JWT: " + userEmail);
                } else {
                    System.out.println("⚠️ Token expired for: " + userEmail);
                }
            }

            filterChain.doFilter(request, response);

        } catch (Exception e) {
            System.out.println("❌ JWT filter error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid or expired token\"}");
        }
    }
}
