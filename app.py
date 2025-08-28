from flask import Flask, jsonify, render_template, request, redirect, url_for
from pymongo import MongoClient
import os

app = Flask(__name__)

# --- MongoDB Connection ---
mongo_uri = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
client = MongoClient(mongo_uri)
db = client["todo_db"]
tasks_collection = db["tasks"]

# --- Routes ---
@app.route("/live")
def live():
    return "live"

@app.route("/")
def index():
    tasks = list(tasks_collection.find())
    return render_template("index.html", tasks=tasks)

@app.route("/add", methods=["POST"])
def add_task():
    task = request.form.get("task")
    if task:
        tasks_collection.insert_one({"task": task})
    return redirect(url_for("index"))
@app.get("/")
def index():
    return jsonify(status="ok", message="Microservice running", version=os.getenv("APP_VERSION", "1.0.0"))

@app.get("/healthz")
def health():
    return "ok", 200

@app.route("/delete/<task_id>")
def delete_task(task_id):
    from bson.objectid import ObjectId
    tasks_collection.delete_one({"_id": ObjectId(task_id)})
    return redirect(url_for("index"))

if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
    #app.run(host="0.0.0.0", port=5000, debug=True)
