package com.example.watertracker.service;

import com.example.watertracker.model.Role;
import com.example.watertracker.model.User;
import com.example.watertracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository repo;
    private final PasswordEncoder encoder;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User u = repo.findByEmail(email).orElseThrow(() -> new UsernameNotFoundException(email));
        var auths = u.getRoles().stream().map(r -> new SimpleGrantedAuthority("ROLE_" + r.name())).toList();
        return new org.springframework.security.core.userdetails.User(u.getEmail(), u.getPasswordHash(), auths);
    }

    public Optional<User> findByEmail(String email) { return repo.findByEmail(email); }
    public User getByEmail(String email) { return findByEmail(email).orElseThrow(); }
    public Optional<User> findByResetToken(String token) { return repo.findByResetToken(token); }

    @Transactional
    public User register(String firstName, String lastName, String email, String password) {
        if (repo.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }

        User u = new User();
        u.setFirstName(firstName);
        u.setLastName(lastName);
        u.setEmail(email);
        u.setPasswordHash(encoder.encode(password));
        u.setRoles(Set.of(Role.USER));

        return repo.save(u);
    }

    @Transactional
    public void setPassword(User u, String raw) {
        u.setPasswordHash(encoder.encode(raw));
    }

    @Transactional
    public void setResetToken(User u, String token, Instant expiry) {
        u.setResetToken(token);
        u.setResetTokenExpiry(expiry);
    }

    @Transactional
    public User updateProfile(Long id, java.util.function.Consumer<User> updater) {
        User u = repo.findById(id).orElseThrow();
        updater.accept(u);
        return u;
    }
}
