#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR

cd $SCRIPT_DIR/downcan
make && ./downcan -d /Users/mtm/pdev/taylormonacelli/eachload/data --verbose

cd $SCRIPT_DIR/eachland
make && ./eachland --root /Users/mtm/pdev/taylormonacelli/eachload/data --actually-delete

cd $SCRIPT_DIR/hiswho
./process_all.sh

docker rm --force myload
docker run --detach --publish 3000:3000 --name myload --env="GF_INSTALL_PLUGINS=marcusolsson-json-datasource" -v /Users/mtm/pdev/taylormonacelli/justmay/sample.yaml:/etc/grafana/provisioning/datasources/sample.yaml grafana/grafana

cd $SCRIPT_DIR/hereville
make && ./hereville

cd $SCRIPT_DIR/myload
set +e
port=8001; pid=$(lsof -t -i :$port); [ -z "$pid" ] || (kill -9 $pid && echo "Process on port $port terminated.") || echo "No process found on port $port."
lsof -t -i:8001
make && ./myload --port=8001 --data-raw /Users/mtm/pdev/taylormonacelli/hiswho/scratch/all.json --data-daily /Users/mtm/pdev/taylormonacelli/hiswho/scratch/daily_import_usage.json -vv &
set -e

cd $SCRIPT_DIR/hiscrime
python upload_dashboard.py
open http://localhost:3000/dashboards
