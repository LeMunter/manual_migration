import requests
import json
import os

login_host = os.environ.get('LOGIN_SERVER_ADDR')
login_port = os.environ.get('LOGIN_SERVER_PORT')

poster_host = os.environ.get('POST_SERVER_ADDR')
poster_port = os.environ.get('POST_SERVER_PORT')

login_svc = f'http://{login_host}:{login_port}'
poster_svc = f'http://{poster_host}:{poster_port}'


def create_user(user, pw):
    print(f'Creating user {user} with pass {pw}')
    po = { 'login': user, 'password': pw}

    r = requests.post(f'{login_svc}/createuser', json=po)
    if not r.ok:
        print('Error')
        exit()


def create_subreddit(s):
    po = {'subreddit':s}
    r = requests.post(f'{poster_svc}/subreddit', json=po)


def login(user, pw):
    print(f'Login for user {user}')
    po = { 'login': user, 'password': pw}

    r = requests.post(f'{login_svc}/login', json=po)
    if r.ok:
        return r.json()['token']
    else:
        print('Error')
        exit()


def post_submission(token, s):
    po = { 'token': token, 'submission' : s}
    r = requests.post(f'{poster_svc}/submission', json=po)

    if not r.ok:
        print('Error')
        exit()


def post_comment(token, c):
    po = { 'token': token, 'comment' : c}
    r = requests.post(f'{poster_svc}/comment', json=po)

    if not r.ok:
        print('Error')
        exit()


with open('data.json') as f:
    jo = json.load(f)

usrdb = {}
tokdb = {}

print('Create user accounts')
for up in jo['users']:
    create_user(up['login'], up['password'])
    usrdb[up['login']] = up['password']

print('Create subreddits')
for sr in jo['subreddits']:
    create_subreddit(sr)

print('Submitting and posting comments')
for sub in jo['submissions']:
    author = sub['author']
    if author not in tokdb:
        tok = login(author, usrdb[author])
        tokdb[author] = tok

    post_submission(tokdb[author], sub)

for cmt in jo['comments']:
    author = cmt['author']
    if author not in tokdb:
        tok = login(author, usrdb[author])
        tokdb[author] = tok

    post_comment(tokdb[author], cmt)
