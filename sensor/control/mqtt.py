#!/usr/bin/env python3
# coding: utf-8
__author__ = "Pedro Pavan"

import paho.mqtt.client as mqtt
import platform
from datetime import datetime
import time
from pin import *

try:
    mqtt_enable = eval(os.getenv("MQTT_ENABLE", "False"))
    mqtt_host = os.getenv("MQTT_HOST")
    mqtt_port = int(os.getenv("MQTT_PORT"))
except:
    raise SystemExit("Variable was not defined!")

def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")
    client.subscribe("florindabox/sensor/temperature",1)
    client.subscribe("florindabox/sensor/humidity",1)
    client.subscribe("florindabox/sensor/buzzer",1)
    client.subscribe("florindabox/sensor/led",1)

def on_message(client, userdata, msg):
    topic = msg.topic
    message = msg.payload.decode("utf-8")
    print(f"[Message] {datetime.now().strftime('%d/%m/%Y %H:%M:%S')} = {message} ({topic})")

    if topic == "florindabox/sensor/buzzer":
        if message == "1":
            beep_on()
        if message == "0":
            beep_off()

    if topic == "florindabox/sensor/led":
        if message == "1":
            led_on()
        if message == "0":
            led_off()

if mqtt_enable:
    print(f"[System] MQTT is enabled")
    client = mqtt.Client(platform.node())
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(mqtt_host, mqtt_port)
    client.loop_forever()
else:
    while True:
        print(f"[System] MQTT is disabled (no action required)")
        time.sleep(60)
