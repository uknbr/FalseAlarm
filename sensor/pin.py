#!/usr/bin/env python3
# coding: utf-8
__author__ = "Pedro Pavan"

import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

def beep_on(pin=18):
        print("[Buzzer] ON")
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.HIGH)

def beep_off(pin=18):
        print("[Buzzer] OFF")
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.LOW)

def led_on(pin=24):
        print("[Led] ON")
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.HIGH)

def led_off(pin=24):
        print("[Led] OFF")
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, GPIO.LOW)