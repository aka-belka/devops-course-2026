#!/usr/bin/env bash
# Доставка статического ресурса на devops-vm
set -euo pipefail

REMOTE="devops"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

# 1. Разбор аргумента --dry-run
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# 2. Проверки по требованиям 4 и 5
if [[ ! -f "${LOCAL_DIR}index.html" ]]; then
    echo "Ошибка: файл ${LOCAL_DIR}index.html не найден. Доставка отменена." >&2
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Ошибка: в репозитории есть незафиксированные изменения. Доставка отменена." >&2
    exit 1
fi

# 3. Синхронизация каталога
RSYNC_OPTS=(-avz --delete --chmod=D755,F644)
if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS+=(--dry-run)
fi

echo "Синхронизация ${LOCAL_DIR} -> ${REMOTE}:${REMOTE_DIR}..."
rsync "${RSYNC_OPTS[@]}" -e "ssh -o BatchMode=yes" "${LOCAL_DIR}" "${REMOTE}:${REMOTE_DIR}/"

# 4. При --dry-run — завершение с кодом 0
if [ "$DRY_RUN" = true ]; then
    echo "Пробный запуск завершен."
    exit 0
fi

# 5. Проверка доступности
echo "Проверка доступности ${SITE_URL}..."
if ! curl -sf --cacert "${CA_CERT}" -o /dev/null "${SITE_URL}"; then
    echo "Ошибка: ресурс ${SITE_URL} недоступен." >&2
    exit 1
fi

echo "Успешно! Доставлен коммит: $(git rev-parse --short HEAD)"
exit 0
