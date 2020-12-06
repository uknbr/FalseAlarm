import RPi.GPIO as GPIO
from DHT11_Python import dht11
import time
import os
import datetime

# DEBUG
#from birdseye import eye
#birdseye --host 0.0.0.0 --port 7010
#@eye

def main():
	GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BCM)
	GPIO.cleanup()

	instance = dht11.DHT11(pin=int(os.getenv('TEMP_GPIO')))
	attempt = int(os.getenv('TEMP_ATTEMPT')) + 1

	print(f"Initializing {os.getenv('APP_NAME')}...")
	count=0

	while True:
		for a in range(1, attempt):
			result = instance.read()
			now = datetime.datetime.now()
			if result.is_valid():
				count += 1
				print('[{0} | {1} | {2}] Temp={3:0.1f}ºC Humidity={4:0.1f}%'.format(count, a, now.strftime("%Y-%m-%d %H:%M:%S"), result.temperature, result.humidity))
				break
			else:
				#print(f"Failed {a} to get reading. Try again!")
				if (a + 1) == attempt:
					print('[{0} | {1} | {2}] Temp={3:0.1f}ºC Humidity={4:0.1f}%'.format(count, a, now.strftime("%Y-%m-%d %H:%M:%S"), 0, 0))
			time.sleep(2)

		time.sleep(int(os.getenv('INTERVAL')))

if __name__ == '__main__':
	main()
