package com.example.watertracker.exception;

import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException e) {
        var first = e.getBindingResult().getFieldErrors().stream().findFirst();
        String msg = first.map(err -> err.getField() + ": " + err.getDefaultMessage()).orElse("Validation failed");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                "timestamp", Instant.now(),
                "error", "ValidationError",
                "message", msg
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handle(Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                "timestamp", Instant.now(),
                "error", e.getClass().getSimpleName(),
                "message", e.getMessage()
        ));
    }
}
