#!/bin/bash

URL="$1"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL")

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "API доступен"
    exit 0
else
    echo "API недоступен, код ответа: $HTTP_CODE"
    exit 1
fi