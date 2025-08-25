FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV MONGO_URI=mongodb://mongodb:27017/
ENV MONGO_USERNAME=root
ENV MONGO_PASSWORD=secret

EXPOSE 5000

CMD ["python", "app.py"]
