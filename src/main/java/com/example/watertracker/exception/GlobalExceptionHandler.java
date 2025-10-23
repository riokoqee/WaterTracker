package com.example.watertracker.exception;

import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.WebRequest;
import java.time.LocalDateTime;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> handle(Exception ex, WebRequest request) {
        return new ResponseEntity<>(
                Map.of(
                        "timestamp", LocalDateTime.now(),
                        "error", ex.getClass().getSimpleName(),
                        "message", ex.getMessage()
                ),
                HttpStatus.BAD_REQUEST
        );
    }
}
