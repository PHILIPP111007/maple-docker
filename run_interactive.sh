#!/bin/bash
# run_interactive.sh - интерактивная сессия с пробросом всех путей

echo "🐚 Запуск интерактивной сессии в контейнере..."

# Пробрасываем все папки
docker run -it --rm \
    -v $(pwd)/input_data:/data/input \
    -v $(pwd)/output:/data/output \
    -v $(pwd)/checkpoints:/data/checkpoints \
    -v $(pwd)/train_dataset:/data/train \
    -v $(pwd)/logs:/data/logs \
    -v $(pwd):/app/ \
    maple:latest \
    /bin/bash -c "export PYTHONPATH=/app/:\$PYTHONPATH && /bin/bash"