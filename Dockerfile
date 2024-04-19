#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
USER app
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["ConsolePro.csproj", "."]
RUN dotnet restore "./././ConsolePro.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./ConsolePro.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./ConsolePro.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Используйте официальный образ MySQL
FROM mysql:latest

# Установите переменные среды
ENV MYSQL_DATABASE=itransition_task4
ENV MYSQL_ROOT_PASSWORD=root

# Откройте порт 3306
EXPOSE 3306

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ConsolePro.dll"]