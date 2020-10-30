FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
COPY . /tmp/
ADD data.json .
ADD medium.json .
ADD small.json .
COPY runexp.py .
ENTRYPOINT ["python","runexp.py"]