#!/bin/bash

STAMP=$(date +"%Y%m%d%H%M")

mkdir -p /results
mkdir -p /results/$STAMP
echo "Results will be saved in /results/$STAMP"

echo "Starting k6 tests, output will be saved in /results/$STAMP"

echo "Starting django-app-v5.0.9..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=django-app-v5.0.9 -e PORT=8000

sleep 2
echo "Starting express-app-v4.18.2..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=express-app-v4.18.2 -e PORT=3100

sleep 2
echo "Starting postgrest-v12.2.3..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=postgrest-v12.2.3 -e PORT=3000 -e REQ_PATH=/rpc/test_func_v1

sleep 2
echo "Starting fastapi-app-v0.103.2..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=fastapi-app-v0.103.2 -e PORT=8001

sleep 2
echo "Starting fastify-app-v4.26.1..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=fastify-app-v4.26.1 -e PORT=3101

sleep 2
echo "Starting deno-app-v1.40.2..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=deno-app-v1.40.2 -e PORT=3102

sleep 2
echo "Starting swoole-php-app-8.3.13..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=swoole-php-app-8.3.13 -e PORT=3103

sleep 2
echo "Starting npgsqlrest-aot-v210..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=npgsqlrest-aot-v210 -e PORT=5000

sleep 2
echo "Starting npgsqlrest-aot-v2.2.1..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=npgsqlrest-aot-v2.2.1 -e PORT=5001

OUTPUT_FILE="/results/$STAMP.csv"
> "$OUTPUT_FILE"
echo "Processing results... Saving to $OUTPUT_FILE"

if ls /results/$STAMP/*.csv 1> /dev/null 2>&1; then
    for file in /results/$STAMP/*.csv; do
        echo "Processing file: $file"
        filename=$(basename "$file" .csv)
        content=$(cat "$file")
        echo "Content read: $content"
        if [ ! -z "$content" ]; then
            echo "$filename,$content" >> "$OUTPUT_FILE"
        else
            echo "Warning: $file is empty"
        fi
    done

    rm /results/$STAMP/*.csv
else
    echo "No CSV files found in /results/$STAMP/"
fi

echo "Results processed and saved to $OUTPUT_FILE"
