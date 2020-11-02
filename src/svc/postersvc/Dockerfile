FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
COPY . /tmp/
COPY post_svc.py .
ENTRYPOINT ["python", "post_svc.py"]