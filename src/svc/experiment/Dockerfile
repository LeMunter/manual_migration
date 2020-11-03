FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
ADD data.json .
ADD medium.json .
ADD small.json .
COPY runexp.py .