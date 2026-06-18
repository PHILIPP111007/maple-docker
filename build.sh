#!/bin/bash
# build.sh - сборка Docker образа с micromamba

echo "Начинаем сборку Docker образа MAPLE с micromamba..."

# Проверяем наличие requirements.txt
if [ ! -f "requirements.txt" ]; then
    echo "Ошибка: requirements.txt не найден!"
    exit 1
fi

# Собираем образ
docker build -t maple:latest \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    .

if [ $? -eq 0 ]; then
    echo "✅ Docker образ MAPLE успешно собран!"
    echo "Размер образа:"
    docker images maple:latest --format "{{.Size}}"
else
    echo "❌ Ошибка при сборке образа!"
    exit 1
fi