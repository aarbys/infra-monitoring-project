#!/bin/bash

LOG_FILE="access.log"
echo "Генерация тестового файла логов..."

IPS=(
    "192.168.1.10"
    "10.0.0.5"
    "172.16.0.3"
    "192.168.1.20"
    "10.0.0.15"
)

METHODS=("GET" "POST" "PUT" "DELETE")
ENDPOINTS=("/api/users" "/api/login" "/api/orders" "/api/products")

> "$LOG_FILE"

for i in $(seq 1 300); do
    IP=${IPS[$((RANDOM % ${#IPS[@]}))]}
    METHOD=${METHODS[$((RANDOM % ${#METHODS[@]}))]}
    ENDPOINT=${ENDPOINTS[$((RANDOM % ${#ENDPOINTS[@]}))]}

    # Генерируем HTTP-код ответа
    CODE=$((RANDOM % 6))

    case $CODE in
        0) CODE=200 ;;
        1) CODE=201 ;;
        2) CODE=400 ;;
        3) CODE=401 ;;
        4) CODE=404 ;;
        5) CODE=500 ;;
    esac

    printf '%s - - [15/Aug/2026:10:%02d:%02d] "%s %s HTTP/1.1" %s\n' \
        "$IP" "$((i / 60))" "$((i % 60))" "$METHOD" "$ENDPOINT" "$CODE" \
        >> "$LOG_FILE"
done

echo "Файл $LOG_FILE создан. Количество строк: $(wc -l < "$LOG_FILE")"

echo ""
echo "===== АНАЛИЗ ЛОГОВ ====="

TOTAL=$(grep -Ec '^[0-9]{1,3}(\.[0-9]{1,3}){3} ' "$LOG_FILE")
echo "Общее количество запросов: $TOTAL"

echo ""
echo "Топ-3 IP-адреса:"
grep -Eo '^[0-9]{1,3}(\.[0-9]{1,3}){3}' "$LOG_FILE" |
    sort |
    uniq -c |
    sort -rn |
    head -3


echo ""
awk '
{
    if ($8 ~ /^4[0-9][0-9]$/) count_4xx++
    if ($8 ~ /^5[0-9][0-9]$/) count_5xx++
}
END {
    print "Количество запросов с кодами 4xx:", count_4xx+0
    print "Количество запросов с кодами 5xx:", count_5xx+0
}' "$LOG_FILE"
