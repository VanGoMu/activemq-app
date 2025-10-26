import logging
import json_log_formatter
import os

LOG_PATH = os.getenv("LOG_PATH", "/app/logs/app.log")

formatter = json_log_formatter.JSONFormatter()
json_handler = logging.FileHandler(LOG_PATH)
json_handler.setFormatter(formatter)

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(json_handler)

# Optional: also log to stdout for Docker
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)
