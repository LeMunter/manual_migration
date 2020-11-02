FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
COPY . /tmp/
ADD templates ./templates
COPY web_svc.py .
ENTRYPOINT ["python","web_svc.py"]