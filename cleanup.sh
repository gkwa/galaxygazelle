#!/bin/bash

echo "🧹 Cleaning up Airflow to clean slate..."

# Stop all Airflow processes
echo "🛑 Stopping Airflow processes..."
if pgrep -f "airflow scheduler" >/dev/null; then
    pkill -f "airflow scheduler"
    echo "✅ Scheduler stopped"
fi

if pgrep -f "airflow api-server" >/dev/null; then
    pkill -f "airflow api-server"
    echo "✅ API server stopped"
fi

if pgrep -f "airflow webserver" >/dev/null; then
    pkill -f "airflow webserver"
    echo "✅ Webserver stopped"
fi

# Delete the DAG from Airflow database
echo "🗑️  Deleting DAG from database..."
airflow dags delete hello_world_dag --yes 2>/dev/null || echo "ℹ️  DAG not found for deletion"

# Remove DAG file
echo "📁 Removing DAG file..."
AIRFLOW_HOME=${AIRFLOW_HOME:-$HOME/airflow}
DAGS_FOLDER=${AIRFLOW__CORE__DAGS_FOLDER:-$AIRFLOW_HOME/dags}
if [ -f "$DAGS_FOLDER/hello_world_dag.py" ]; then
    rm "$DAGS_FOLDER/hello_world_dag.py"
    echo "✅ DAG file removed"
else
    echo "ℹ️  DAG file not found"
fi

# Remove log files
echo "📝 Removing log files..."
rm -f scheduler.log api-server.log webserver.log
rm -f *.pid

# Reset Airflow database to clean slate
echo "🗄️  Resetting Airflow database..."
airflow db reset --yes

# Clean up any example DAGs cache
echo "🧹 Cleaning up caches..."
rm -rf "$DAGS_FOLDER/__pycache__" 2>/dev/null || true

echo "✅ Airflow cleaned to pristine state!"
echo "🚀 Ready for fresh e2e test with: ./e2e-test.sh"
