#!/bin/bash
# run_training.sh - запуск обучения с пробросом путей

set -e

show_help() {
    echo "Использование: ./run_training.sh [OPTIONS]"
    echo ""
    echo "Опции:"
    echo "  -d, --data PATH       Путь к данным для обучения (обязательно)"
    echo "  -o, --output PATH     Путь для сохранения модели и логов (по умолчанию: ./logs)"
    echo "  -c, --checkpoints PATH Путь для сохранения чекпоинтов (по умолчанию: ./checkpoints)"
    echo "  -t, --type TYPE       Тип задачи: EpigeneticAge, CVD, T2D (по умолчанию: EpigeneticAge)"
    echo "  -h, --help            Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  ./run_training.sh -d ./train_dataset/epiAge_traindata.npz"
    echo "  ./run_training.sh -d ./data/train.npz -o ./my_logs -t CVD"
}

# Значения по умолчанию
DATA=""
OUTPUT="./logs"
CHECKPOINTS="./checkpoints"
TASK_TYPE="EpigeneticAge"

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--data)
            DATA="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -c|--checkpoints)
            CHECKPOINTS="$2"
            shift 2
            ;;
        -t|--type)
            TASK_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# Проверяем обязательные аргументы
if [ -z "$DATA" ]; then
    echo "❌ Ошибка: необходимо указать -d (путь к данным)"
    show_help
    exit 1
fi

# Проверяем существование файла
if [ ! -f "$DATA" ]; then
    echo "❌ Файл с данными не найден: $DATA"
    exit 1
fi

# Создаем директории
mkdir -p "$OUTPUT" "$CHECKPOINTS"

echo "🚀 Запуск обучения MAPLE..."
echo "  Данные: $DATA"
echo "  Выход: $OUTPUT"
echo "  Чекпоинты: $CHECKPOINTS"
echo "  Тип задачи: $TASK_TYPE"

# Получаем абсолютные пути
DATA_ABS=$(realpath "$DATA")
OUTPUT_ABS=$(realpath "$OUTPUT")
CHECKPOINTS_ABS=$(realpath "$CHECKPOINTS")

# Запускаем контейнер
docker run --rm \
    -v "$DATA_ABS:/data/train/data.npz:ro" \
    -v "$OUTPUT_ABS:/data/logs" \
    -v "$CHECKPOINTS_ABS:/data/checkpoints" \
    maple:latest \
    python /app/MAPLE_train.py \
        --problem_type "$TASK_TYPE" \
        --data_source "/data/train/data.npz" \
        --path_save "/data/logs"

echo "✅ Обучение завершено!"
echo "  Модель сохранена в: $OUTPUT_ABS"
echo "  Чекпоинты в: $CHECKPOINTS_ABS"