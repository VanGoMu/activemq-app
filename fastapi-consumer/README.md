# FastAPI ActiveMQ Consumer

Consumes messages from ActiveMQ queue and identifies itself by SERVICE_ID.

## Usage

1. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```
2. Start the app:
   ```sh
   SERVICE_ID=Consumer1 uvicorn main:app --reload --port 8001
   SERVICE_ID=Consumer2 uvicorn main:app --reload --port 8002
   ```
3. Consume a message:
   ```sh
   curl http://localhost:8001/consume
   curl http://localhost:8002/consume
   ```

## Docker Compose

This service can be started multiple times with different SERVICE_ID and ports using Docker Compose.
