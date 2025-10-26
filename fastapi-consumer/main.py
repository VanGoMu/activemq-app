from fastapi import FastAPI
import stomp
import os

app = FastAPI()

ACTIVEMQ_HOST = os.getenv("ACTIVEMQ_HOST", "localhost")
ACTIVEMQ_PORT = int(os.getenv("ACTIVEMQ_STOMP_PORT", "61613"))
ACTIVEMQ_USER = os.getenv("ACTIVEMQ_ADMIN_LOGIN", "admin")
ACTIVEMQ_PASS = os.getenv("ACTIVEMQ_ADMIN_PASSWORD", "admin")
QUEUE_NAME = os.getenv("ACTIVEMQ_QUEUE", "/queue/test.queue")
SERVICE_ID = os.getenv("SERVICE_ID", "Consumer")

@app.get("/consume")
def consume_message():
    conn = stomp.Connection12([(ACTIVEMQ_HOST, ACTIVEMQ_PORT)])
    conn.connect(ACTIVEMQ_USER, ACTIVEMQ_PASS, wait=True)
    messages = []
    class Listener(stomp.ConnectionListener):
        def on_message(self, frame):
            messages.append(frame.body)
            conn.disconnect()
    conn.set_listener('', Listener())
    conn.subscribe(destination=QUEUE_NAME, id=1, ack='auto')
    import time
    time.sleep(2)  # Wait for message
    if messages:
        return {"service": SERVICE_ID, "message": messages[0]}
    else:
        conn.disconnect()
        return {"service": SERVICE_ID, "message": None, "info": "No message received"}
