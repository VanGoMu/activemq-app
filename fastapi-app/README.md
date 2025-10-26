# FastAPI to ActiveMQ Example

This app receives HTTP requests and writes messages to an ActiveMQ queue using STOMP.

## Usage

1. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```

2. Start the FastAPI app:
   ```sh
   uvicorn main:app --reload
   ```

3. Send a POST request to `/send`:
   ```sh
   curl -X POST http://localhost:8000/send -H "Content-Type: application/json" -d '{"body": "Hello from FastAPI!"}'
   ```

## Environment Variables
- ACTIVEMQ_HOST (default: localhost)
- ACTIVEMQ_STOMP_PORT (default: 61613)
- ACTIVEMQ_ADMIN_LOGIN (default: admin)
- ACTIVEMQ_ADMIN_PASSWORD (default: admin)
- ACTIVEMQ_QUEUE (default: /queue/test.queue)

You can set these variables to match your ActiveMQ configuration.
