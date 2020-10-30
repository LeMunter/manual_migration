FROM python:3.8
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt
COPY . /tmp/
COPY login_svc.py .
ENTRYPOINT ["gunicorn", "login_svc.py"]