import os
from flask import Flask, jsonify
from flask_mysqldb import MySQL
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# Initialize Prometheus metrics
metrics = PrometheusMetrics(app)

mysql = MySQL()

# MySQL configurations (from environment variables) - No default fallbacks for security
app.config['MYSQL_HOST'] = os.getenv("MYSQL_DATABASE_HOST")
app.config['MYSQL_USER'] = os.getenv("MYSQL_DATABASE_USER")
app.config['MYSQL_PASSWORD'] = os.getenv("MYSQL_DATABASE_PASSWORD")
app.config['MYSQL_DB'] = os.getenv("MYSQL_DATABASE_DB")

# Validate required environment variables
required_env_vars = ['MYSQL_DATABASE_HOST', 'MYSQL_DATABASE_USER', 'MYSQL_DATABASE_PASSWORD', 'MYSQL_DATABASE_DB']
for var in required_env_vars:
    if not os.getenv(var):
        raise ValueError(f"{var} environment variable is required")

mysql.init_app(app)

@app.route("/")
def main():
    return jsonify({"message": "Welcome!", "status": "healthy"})

@app.route("/health")
def health():
    return jsonify({"message": "I am good, how about you?", "status": "healthy"})

@app.route("/employees")
def read_employees():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM employees")
        rows = cursor.fetchall()
        
        if not rows:
            return jsonify({"message": "No employees found", "data": []}), 200
        
        # Convert to proper JSON format
        employees = []
        for row in rows:
            employees.append({
                "id": row[0],
                "data": str(row[0])  # Keeping original logic
            })
        
        cursor.close()
        return jsonify({"message": "Success", "data": employees}), 200
        
    except Exception as e:
        app.logger.error(f"Database error: {str(e)}")
        return jsonify({"error": "Database connection failed", "message": str(e)}), 500

# Health check endpoint for Kubernetes
@app.route("/healthz")
def healthz():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        return jsonify({"status": "healthy", "database": "connected"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "database": "disconnected", "error": str(e)}), 500

@app.route("/metrics")
def metrics_endpoint():
    """Prometheus metrics endpoint"""
    return metrics.generate_latest()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)