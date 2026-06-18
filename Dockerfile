# MAPLE Dockerfile с micromamba (исправленный)

FROM mambaorg/micromamba:latest

# Устанавливаем переменные окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"

# Переключаемся на root для установки системных зависимостей
USER root

# 1. Устанавливаем системные зависимости (включая R)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libfontconfig1 \
    libcairo2 \
    libxt6 \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libz-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre2-dev \
    make \
    g++ \
    gfortran \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Создаем пользователя (если его нет)
RUN id -u mambauser &>/dev/null || useradd -m -s /bin/bash mambauser

# 3. Возвращаемся к пользователю
USER mambauser

# 4. Устанавливаем пути для micromamba
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"

# 5. Создаем окружение maple с Python
RUN micromamba create -y -n maple python=3.10 && \
    micromamba clean --all --yes

# 6. Устанавливаем R-пакеты через R
RUN micromamba run -n maple R -e "install.packages('data.table', repos='https://cloud.r-project.org/')" && \
    micromamba run -n maple R -e "install.packages('devtools', repos='https://cloud.r-project.org/')" && \
    micromamba run -n maple R -e "install.packages('tidyverse', repos='https://cloud.r-project.org/')" && \
    micromamba run -n maple R -e "install.packages('ENmix', repos='https://cloud.r-project.org/')" && \
    micromamba run -n maple R -e "if (!require('BiocManager', quietly = TRUE)) install.packages('BiocManager')" && \
    micromamba run -n maple R -e "BiocManager::install('minfi', update=FALSE, ask=FALSE)" && \
    micromamba run -n maple R -e "BiocManager::install('GMQN', update=FALSE, ask=FALSE)" || true

# 7. Копируем requirements.txt и устанавливаем Python-пакеты
COPY requirements.txt /tmp/requirements.txt
RUN micromamba run -n maple pip install --upgrade pip && \
    micromamba run -n maple pip install --no-cache-dir -r /tmp/requirements.txt

# 6. Копируем проект MAPLE в папку /app/MAPLE
WORKDIR /app
COPY MAPLE/ /app/

# 7. Копируем entrypoint скрипт
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# 9. Создаем директории
RUN mkdir -p /app/checkpoints /app/input_data /app/output /app/raw_data /app/logs

# 10. Настраиваем активацию окружения
ENV PATH="/opt/conda/envs/maple/bin:${PATH}"

# 11. Точка входа (используем стандартный скрипт из образа)
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

# 12. Команда по умолчанию
CMD ["python", "/app/MAPLE/MAPLE_inference.py", "--help"]