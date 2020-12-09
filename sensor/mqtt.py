#!/usr/bin/env python3
# coding: utf-8
__author__ = "Pedro Pavan"

import paho.mqtt.client as mqtt
import platform
from pin import *

def on_connect(client, userdata, flags, rc):
        print(f"Connected with result code {rc}")
        client.subscribe("florindabox/sensor/temperature",1)
        client.subscribe("florindabox/sensor/humidity",1)
        client.subscribe("florindabox/sensor/buzzer",1)
        client.subscribe("florindabox/sensor/led",1)

def on_message(client, userdata, msg):
        topic = msg.topic
        message = msg.payload.decode("utf-8")
        print(f"Message received --> {topic} = {message}")

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

client = mqtt.Client(platform.node())
client.on_connect = on_connect
client.on_message = on_message
client.connect("localhost", 1883)
client.loop_forever()