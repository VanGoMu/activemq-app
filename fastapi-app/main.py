from fastapi import FastAPI, Request
from pydantic import BaseModel
import stomp
import os
import logging
import datetime
from logging_config import logger

class Message(BaseModel):
    body: str

app = FastAPI()

ACTIVEMQ_HOST = os.getenv("ACTIVEMQ_HOST", "localhost")
ACTIVEMQ_PORT = int(os.getenv("ACTIVEMQ_STOMP_PORT", "61613"))
ACTIVEMQ_USER = os.getenv("ACTIVEMQ_ADMIN_LOGIN", "admin")
ACTIVEMQ_PASS = os.getenv("ACTIVEMQ_ADMIN_PASSWORD", "admin")
QUEUE_NAME = os.getenv("ACTIVEMQ_QUEUE", "/queue/test.queue")

@app.post("/send")
def send_message(msg: Message, request: Request):
    conn = stomp.Connection12([(ACTIVEMQ_HOST, ACTIVEMQ_PORT)])
    conn.connect(ACTIVEMQ_USER, ACTIVEMQ_PASS, wait=True)
    conn.send(destination=QUEUE_NAME, body=msg.body)
    conn.disconnect()
    logger.info({
        "event": "message_sent",
        "queue": QUEUE_NAME,
        "body": msg.body,
        "client": request.client.host,
        "@timestamp": datetime.datetime.utcnow().isoformat() + "Z"
    })
    return {"status": "sent", "queue": QUEUE_NAME, "body": msg.body}
