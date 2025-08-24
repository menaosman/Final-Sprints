import os
from flask import Flask
from flaskext.mysql import MySQL

app = Flask(__name__)

mysql = MySQL()

# MySQL configurations (from environment variables)
app.config['MYSQL_DATABASE_USER'] = os.getenv("MYSQL_DATABASE_USER", "db_user")
app.config['MYSQL_DATABASE_PASSWORD'] = os.getenv("MYSQL_DATABASE_PASSWORD", "Passw0rd")
app.config['MYSQL_DATABASE_DB'] = os.getenv("MYSQL_DATABASE_DB", "employee_db")
app.config['MYSQL_DATABASE_HOST'] = os.getenv("MYSQL_DATABASE_HOST", "localhost")

mysql.init_app(app)

@app.route("/")
def main():
    return "Welcome!"

@app.route("/how are you")
def hello():
    return "I am good, how about you?"

@app.route("/read from database")
def read():
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM employees")
    rows = cursor.fetchall()
    result = [str(row[0]) for row in rows]
    cursor.close()
    conn.close()
    return ",".join(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
