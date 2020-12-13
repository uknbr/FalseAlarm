#!/usr/bin/env python3
# coding: utf-8
__author__ = "Pedro Pavan"

import RPi.GPIO as GPIO
import os

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

try:
    led_pin = int(os.getenv("LED_GPIO"))
    buz_pin = int(os.getenv("BUZ_GPIO"))
except:
    raise SystemExit("Variable was not defined!")

def beep_on():
        print("[Buzzer] ON")
        GPIO.setup(buz_pin, GPIO.OUT)
        GPIO.output(buz_pin, GPIO.HIGH)

def beep_off():
        print("[Buzzer] OFF")
        GPIO.setup(buz_pin, GPIO.OUT)
        GPIO.output(buz_pin, GPIO.LOW)

def led_on():
        print("[Led] ON")
        GPIO.setup(led_pin, GPIO.OUT)
        GPIO.output(led_pin, GPIO.HIGH)

def led_off():
        print("[Led] OFF")
        GPIO.setup(led_pin, GPIO.OUT)
        GPIO.output(led_pin, GPIO.LOW)