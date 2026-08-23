import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "capstone_db"),
        user=os.getenv("DB_USER", "capstone_user"),
        password=os.getenv("DB_PASSWORD", "capstone_password")
    )


@app.route("/")
def home():
    return """
    <h1>DevOps Capstone Project</h1>
    <h2>Automated Cloud Deployment Pipeline</h2>
    <p>Application Status: Running</p>
    <p>Welcome to my AWS DevOps deployment.</p>
    """


@app.route("/health")
def health():
    try:
        connection = get_db_connection()
        connection.close()

        return jsonify(
            status="healthy",
            application="running",
            database="connected"
        ), 200

    except Exception as error:
        return jsonify(
            status="unhealthy",
            application="running",
            database="disconnected",
            error=str(error)
        ), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)