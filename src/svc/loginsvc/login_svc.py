#!/usr/bin/env python
from flask import Flask, g, request, jsonify, abort
import pymysql.cursors
import string
import random
import os


app = Flask(__name__)

mariadb_host = os.environ.get('MARIADB_SERVER_ADDR')
mariadb_port = os.environ.get('MARIADB_SERVER_PORT')
mariadb_user = os.environ.get('MARIADB_DB_USER')
mariadb_pw = os.environ.get('MARIADB_DB_PASSWORD')
mariadb_db = os.environ.get('MARIADB_DB_NAME')


def gentok():
    return ''.join(random.choice( string.ascii_letters + string.digits + '.!-_,') for i in range(32))


def get_db():
    if not hasattr(g, 'mariadb'):
        g.mariadb = pymysql.connect(host=mariadb_host, 
                                    port=int(mariadb_port),
                                    user=mariadb_user, 
                                    password=mariadb_pw, 
                                    db=mariadb_db ,
                                    cursorclass=pymysql.cursors.DictCursor)
    return g.mariadb


@app.teardown_appcontext
def close_db(error):
    if hasattr(g, 'mariadb'):
        g.mariadb.close()


@app.route('/createuser', methods=['POST'])
def create_user():
    conn = get_db()
    data = request.json
    with conn.cursor() as curs:
        curs.execute('INSERT IGNORE INTO users VALUES (%s,%s)', (data['login'], data['password']))

    conn.commit()
    return jsonify(success=True)


@app.route('/login', methods=['POST'])
def login():
    conn = get_db()
    data = request.json
    with conn.cursor() as curs:
        curs.execute('SELECT password FROM users WHERE login=%s', (data['login'],))
        res = curs.fetchone()
        if res['password'] != data['password']:
            abort(404)
        tok = gentok()
        curs.execute('INSERT INTO loggedin VALUES (%s, %s)', (tok, data['login']))
    conn.commit()

    return jsonify({'success':True, 'token': tok})


@app.route('/logout', methods=['POST'])
def logout():
    conn = get_db()
    token = request.form['token']
    with conn.cursor() as curs:
        curs.execute('DELETE FROM loggedin WHERE token=%s', (token,))

    conn.commit()

    return jsonify({'success':True})


@app.route('/check', methods=['POST'])
def check():
    conn = get_db()
    data = request.json
    with conn.cursor() as curs:
        res = curs.execute('SELECT * FROM loggedin WHERE token=%s', (data['token'],))
        if res == 0:
            abort(404)

    return jsonify({'success':True})


if __name__ == '__main__':
    app.run('0.0.0.0', port=7070)
