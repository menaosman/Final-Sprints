import os
from flask import Flask
from flask_mysqldb import MySQL


app = Flask(__name__)
mysql = MySQL()

# Get database configuration from environment variables
# These should match your GitHub secrets/variables
mysql_host = os.environ.get('MYSQL_DATABASE_HOST', 'localhost')
mysql_user = os.environ.get('MYSQL_DATABASE_USER', 'db_user') 
mysql_password = os.environ.get('MYSQL_DATABASE_PASSWORD', 'Passw0rd')
mysql_db = os.environ.get('MYSQL_DATABASE_DB', 'employee_db')

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = mysql_user
app.config['MYSQL_DATABASE_PASSWORD'] = mysql_password
app.config['MYSQL_DATABASE_DB'] = mysql_db
app.config['MYSQL_DATABASE_HOST'] = mysql_host

mysql.init_app(app)

@app.route("/")
def main():
    return "Welcome to Employee Management System!"

@app.route("/health")
def health():
    return "OK"

@app.route("/live")
def live():
    return "live"

@app.route('/how-are-you')
def hello():
    return 'I am good, how about you?'

@app.route('/employees')
def read():
    try:
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM employees")
        rows = cursor.fetchall()
        result = []
        for row in rows:
            result.append(str(row[0]))
        cursor.close()
        conn.close()
        return ",".join(result) if result else "No employees found"
    except Exception as e:
        return f"Database error: {str(e)}", 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=False)