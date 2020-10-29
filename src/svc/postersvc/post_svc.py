#!/usr/bin/env python
from flask import Flask, g, request, jsonify, abort
import pymongo
import os
import requests

login_host = os.environ.get('LOGIN_SERVER_ADDR')
login_port = os.environ.get('LOGIN_SERVER_PORT')

login_svc = f'http://{login_host}:{login_port}'

mongo_host = os.environ.get('MONGO_SERVER_ADDR')
mongo_port = os.environ.get('MONGO_SERVER_PORT')
mongo_user = os.environ.get('MONGO_DB_USER')
mongo_pw = os.environ.get('MONGO_DB_PASSWORD')


login_svc = f'http://{login_host}:{login_port}'

app = Flask(__name__)


def get_db():
    if not hasattr(g, 'mongodb'):
        g.mongodb = pymongo.MongoClient(mongo_host, 
                                        port=int(mongo_port), 
                                        username=mongo_user, 
                                        password=mongo_pw, 
                                        authSource='admin')
    return g.mongodb


@app.teardown_appcontext
def close_db(error):
    if hasattr(g, 'mongodb'):
        g.mongodb.close()

@app.route('/subreddits', methods=['GET'])
def subreddits():
    client = get_db()
    res = client.MiniReddit.Subreddits.find()

    subs = []
    for sr in res:
        subs.append(sr['subreddit'])

    return jsonify({'success':True, 'subreddits': subs})


@app.route('/subreddit', methods=['POST'])
def subreddit():
    client = get_db()
    data = request.json
    client.MiniReddit.Subreddits.update_one({'subreddit': data['subreddit']}, {'$setOnInsert': data}, upsert=True)

    return jsonify({'success':True})


@app.route('/submissions', methods=['GET'])
def submissions():
    q = {}
    if 'subreddit' in request.args:
        q['subreddit'] = request.args.get('subreddit')

    if 'author' in request.args:
        q['author'] = request.args.get('author')

    client = get_db()
    res = client.MiniReddit.Submissions.find(q)
    rs = []
    for r in res:
        del r['_id']
        rs.append(r)

    return jsonify({'success':True, 'submissions': rs})


@app.route('/submission', methods=['GET', 'POST'])
def submission():
    client = get_db()
    if request.method == 'POST':
        data = request.json
        r = requests.post(f'{login_svc}/check', json={'token': data['token']})
        if not r.ok:
            abort(404)
        client.MiniReddit.Submissions.update_one({'id': data['submission']['id']}, {'$setOnInsert': data['submission']}, upsert=True)
        return jsonify({'success':True})
    else:
        sid = request.args.get('id', None)
        if not sid:
            abort(404)
        res = client.MiniReddit.Submissions.find_one({'id': sid})
        if not res:
            abort(404)
        del res['_id']
        return jsonify({'success':True, 'submission': res})


@app.route('/comments', methods=['GET'])
def comments():
    q = {}

    if 'submission' in request.args:
        q['link_id'] = request.args.get('submission')

    if 'subreddit' in request.args:
        q['subreddit'] = request.args.get('subreddit')

    if 'author' in request.args:
        q['author'] = request.args.get('author')

    client = get_db()
    res = client.MiniReddit.Comments.find(q)
    rs = []
    for r in res:
        del r['_id']
        rs.append(r)

    return jsonify({'success':True, 'comments': rs})


@app.route('/comment', methods=['GET', 'POST'])
def comment():
    client = get_db()
    if request.method == 'POST':
        data = request.json
        r = requests.post(f'{login_svc}/check', json={'token': data['token']})
        if not r.ok:
            abort(404)
        client.MiniReddit.Comments.update_one({'id': data['comment']['id']}, {'$setOnInsert': data['comment']}, upsert=True)
        return jsonify({'success':True})
    else:
        sid = request.args.get('id', None)
        if not sid:
            abort(404)
        res = client.MiniReddit.Comments.find_one({'id': sid})
        if not res:
            abort(404)
        del res['_id']
        return jsonify({'success':True, 'comment': res})

if __name__ == '__main__':
    app.run('0.0.0.0', port=7075)
