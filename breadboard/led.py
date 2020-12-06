import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(24,GPIO.OUT)

for i in range(100):
	print(f"[{i}] LED on")
	GPIO.output(24,GPIO.HIGH)
	time.sleep(2)

	print(f"[{i}] LED off")
	GPIO.output(24,GPIO.LOW)
	time.sleep(1)