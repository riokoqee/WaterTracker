# ===============================
#  Этап 1: Сборка проекта (build)
# ===============================
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем pom.xml и загружаем зависимости (для кеширования)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Копируем исходный код и собираем jar-файл
COPY src ./src
RUN mvn clean package -DskipTests


# ===============================
#  Этап 2: Запуск (runtime)
# ===============================
FROM eclipse-temurin:17-jdk-alpine

# Устанавливаем директорию приложения
WORKDIR /app

# Копируем jar из предыдущего этапа
COPY --from=builder /app/target/*.jar app.jar

# Устанавливаем переменные окружения
ENV SPRING_PROFILES_ACTIVE=prod \
    TZ=Asia/Almaty

# Порт, на котором будет слушать Spring Boot
EXPOSE 8080

# Команда запуска
ENTRYPOINT ["java", "-jar", "app.jar"]
