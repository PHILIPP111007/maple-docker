#!/bin/bash
# run_inference.sh - запуск inference с пробросом путей

set -e

# Функция для отображения помощи
show_help() {
    echo "Использование: ./run_inference.sh [OPTIONS]"
    echo ""
    echo "Опции:"
    echo "  -b, --beta PATH       Путь к файлу с бета-матрицей (обязательно)"
    echo "  -m, --meta PATH       Путь к файлу с метаданными (обязательно)"
    echo "  -o, --output PATH     Путь для сохранения результата (по умолчанию: ./output/result.csv)"
    echo "  -c, --checkpoints PATH Путь к папке с чекпоинтами (по умолчанию: ./checkpoints)"
    echo "  -i, --input PATH      Путь к папке с входными данными (по умолчанию: ./input_data)"
    echo "  -h, --help            Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  ./run_inference.sh -b ./my_data/beta.csv -m ./my_data/meta.csv"
    echo "  ./run_inference.sh -b ./data/beta.csv -m ./data/meta.csv -o ./results/pred.csv -c ./models/"
}

# Значения по умолчанию
BETA=""
META=""
OUTPUT="./output/result.csv"
CHECKPOINTS="./checkpoints"
INPUT_DATA="./input_data"

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--beta)
            BETA="$2"
            shift 2
            ;;
        -m|--meta)
            META="$2"
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
        -i|--input)
            INPUT_DATA="$2"
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
if [ -z "$BETA" ] || [ -z "$META" ]; then
    echo "❌ Ошибка: необходимо указать -b (бета-матрица) и -m (метаданные)"
    show_help
    exit 1
fi

# Проверяем существование файлов
if [ ! -f "$BETA" ]; then
    echo "❌ Файл бета-матрицы не найден: $BETA"
    exit 1
fi

if [ ! -f "$META" ]; then
    echo "❌ Файл метаданных не найден: $META"
    exit 1
fi

if [ ! -d "$CHECKPOINTS" ]; then
    echo "⚠️  Папка с чекпоинтами не найдена: $CHECKPOINTS"
    echo "Создаю папку..."
    mkdir -p "$CHECKPOINTS"
fi

# Создаем директорию для результата
mkdir -p $(dirname "$OUTPUT")

echo "🚀 Запуск MAPLE inference..."
echo "  Бета-матрица: $BETA"
echo "  Метаданные: $META"
echo "  Результат: $OUTPUT"
echo "  Чекпоинты: $CHECKPOINTS"

# Получаем абсолютные пути
BETA_ABS=$(realpath "$BETA")
META_ABS=$(realpath "$META")
OUTPUT_ABS=$(realpath "$(dirname "$OUTPUT")")/$(basename "$OUTPUT")
CHECKPOINTS_ABS=$(realpath "$CHECKPOINTS")

# Запускаем контейнер
docker run --rm \
    -v "$BETA_ABS:/data/input/beta.csv:ro" \
    -v "$META_ABS:/data/input/meta.csv:ro" \
    -v "$OUTPUT_ABS:/data/output/result.csv" \
    -v "$CHECKPOINTS_ABS:/data/checkpoints:ro" \
    maple:latest \
    python /app/MAPLE_inference.py \
        --input_path "/data/input/beta.csv" \
        --sample_info "/data/input/meta.csv" \
        --output_path "/data/output/result.csv"

echo "✅ Результат сохранен в ${OUTPUT}"