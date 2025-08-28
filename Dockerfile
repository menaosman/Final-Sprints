FROM python:3.10-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

#COPY requirements.txt .
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

#COPY . .
COPY . /app

ENV MONGO_URI=mongodb://mongodb:27017/
ENV MONGO_USERNAME=root
ENV MONGO_PASSWORD=secret

EXPOSE 5000

#CMD ["python", "app.py"]

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "app:app"]
