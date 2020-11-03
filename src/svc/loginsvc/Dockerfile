FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
COPY login_svc.py .
ENTRYPOINT ["python", "login_svc.py"]