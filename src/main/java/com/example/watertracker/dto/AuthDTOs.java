package com.example.watertracker.dto;

import jakarta.validation.constraints.*;
import lombok.*;

public class AuthDTOs {

    @Getter @Setter
    public static class RegisterRequest {
        @NotBlank public String firstName;
        @NotBlank public String lastName;
        @Email @NotBlank public String email;
        @Size(min = 6) @NotBlank public String password;
    }

    @Getter @Setter
    public static class LoginRequest {
        @Email @NotBlank public String email;
        @NotBlank public String password;
    }

    @Getter @Setter
    public static class GoogleLoginRequest {
        @NotBlank public String idToken; // фронт пришлёт idToken; тут мы просто создадим/отдадим пользователя (учебно)
        @NotBlank public String email;   // подстраховка
        @NotBlank public String firstName;
        @NotBlank public String lastName;
    }

    @Getter @Setter
    public static class ForgotPasswordRequest {
        @Email @NotBlank public String email;
    }

    @Getter @Setter
    public static class ResetPasswordRequest {
        @NotBlank public String token;
        @Size(min=6) @NotBlank public String newPassword;
    }

    @Getter @Setter @AllArgsConstructor
    public static class TokenResponse { public String token; }
}
