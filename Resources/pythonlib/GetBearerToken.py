#!/usr/bin/env python
import json
import requests
from typing import Tuple
from robot.api.deco import keyword, library


@library
class GetBearerToken:

    def __init__(self, endpoint: str):
        self.endpoint = endpoint

    @keyword
    def get_bearer_token(self, headers: dict, user_id: str or int, username: str, password: str) -> Tuple[requests, str]:

        data = {
            "id": user_id,
            "username": username,
            "password": password
        }

        print(data)
        r = requests.post(self.endpoint, data=json.dumps(data), headers=headers)
        try:
            token = json.loads(r.text)['access_token']
        except KeyError as e:
            print('no access_token found, continuing', e)
            token = ''
        return r, token


if __name__ == '__main__':
    inst = GetBearerToken('http://localhost:8080/v1/proxy/tokens/')
    r, token = inst.get_bearer_token({"Content-Type": "application/json", "accept": "application/json"}, 1, 'testadmin', 'admin')
    print(r, token)
