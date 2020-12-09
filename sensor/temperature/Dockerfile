FROM arm32v7/python:3.7.4-stretch
RUN apt-get update && apt-get install -y git build-essential
WORKDIR /florindaApp
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN git clone https://github.com/allthingsclowd/DHT11_Python.git
COPY sensor.py .
ENTRYPOINT ["/usr/local/bin/python3", "sensor.py"]