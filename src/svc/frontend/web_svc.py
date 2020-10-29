#!/usr/bin/env python
from flask import Flask, g, request, jsonify, abort
from flask.templating import render_template
import os
import requests

login_host = os.environ.get('LOGIN_SERVER_ADDR')
login_port = os.environ.get('LOGIN_SERVER_PORT')

poster_host = os.environ.get('POST_SERVER_ADDR')
poster_port = os.environ.get('POST_SERVER_PORT')

frontend_host = os.environ.get('FRONTEND_SERVER_ADDR')
frontend_port = os.environ.get('FRONTEND_SERVER_PORT')

login_svc = f'http://{login_host}:{login_port}'
poster_svc = f'http://{poster_host}:{poster_port}'
frontend = f'http://{frontend_host}:{frontend_port}'

app = Flask(__name__)

@app.route('/')
def index():
    r = requests.get(f'{poster_svc}/subreddits')
    if not r.ok:
        abort(404)
    j = r.json()

    subs = []
    for s in j['subreddits']:
        subs.append({'name': s, 'url': f'{frontend}/r/{s}'})

    return render_template('subreddits.html', subs=subs, title='MiniReddit')


@app.route('/r/<sr>')
def subreddit(sr):
    r = requests.get(f'{poster_svc}/submissions', params={'subreddit': sr})
    
    if not r.ok:
        abort(404)
    j = r.json()

    subs = []
    for s in j['submissions']:
        subs.append({'title': s['title'], 'author': s['author'], 'url': f'{frontend}/s/{s["id"]}'})

    return render_template('submissions.html', subs=subs, title=sr)


@app.route('/s/<sid>')
def submission(sid):
    r = requests.get(f'{poster_svc}/submission', params={'id': sid})
    if not r.ok:
        abort(404)
    j = r.json()
    sub = j['submission']

    r = requests.get(f'{poster_svc}/comments', params={'submission': sid})
    if not r.ok:
        abort(404)
    j = r.json()
    cmts = []
    for c in j['comments']:
        cmts.append({'author': c['author'], 'body': c['body']})

    return render_template('submission.html', sub=sub, cmts=cmts, title=sub['title'])




if __name__ == '__main__':
    app.run('0.0.0.0', port=7080)
