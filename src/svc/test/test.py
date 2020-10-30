#!/usr/bin/env python
from flask import Flask, request, g , jsonify
import os
import socket

json_data = '{"test_var": test, "test_var2": test2}'

app = Flask(__name__, static_url_path='/static/')

@app.route("/")
def index2():
    return jsonify({"host": socket.gethostname()})

@app.route("/vars")
def index():
    return os.environ.get('test_var') + " " + os.environ.get('test_var2') + "\n"


if __name__ == '__main__':
    app.run('0.0.0.0', port=65531)