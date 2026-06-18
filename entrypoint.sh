#!/bin/bash
# entrypoint.sh - активирует окружение через micromamba

# Инициализируем micromamba
export MAMBA_ROOT_PREFIX=/opt/mamba
export PATH="${MAMBA_ROOT_PREFIX}/bin:${PATH}"

# Активируем окружение
source /etc/profile.d/mamba.sh
micromamba activate maple

# Проверяем, что все работает
python --version
R --version

# Выполняем переданную команду
exec "$@"