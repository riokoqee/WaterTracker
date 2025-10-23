package com.example.watertracker.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.Map;

@Component
public class JwtUtil {
    private final Key key;
    private final long accessMinutes;
    private final long refreshMinutes;

    public JwtUtil(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.accessMinutes}") long accessMinutes,
            @Value("${jwt.refreshMinutes}") long refreshMinutes
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
        this.accessMinutes = accessMinutes;
        this.refreshMinutes = refreshMinutes;
    }

    public String generateAccess(String subject, Map<String, Object> claims) {
        return buildToken(subject, claims, accessMinutes, "access");
    }

    public String generateRefresh(String subject, Map<String, Object> claims) {
        return buildToken(subject, claims, refreshMinutes, "refresh");
    }

    private String buildToken(String subject, Map<String, Object> claims, long minutes, String typ) {
        Instant now = Instant.now();
        claims.put("typ", typ);
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(now.plusSeconds(minutes * 60)))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String getSubject(String token) {
        return parse(token).getBody().getSubject();
    }

    public String getType(String token) {
        Object t = parse(token).getBody().get("typ");
        return t == null ? "" : t.toString();
    }

    public boolean isExpired(String token) {
        return parse(token).getBody().getExpiration().before(new Date());
    }

    private Jws<Claims> parse(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
    }
}
