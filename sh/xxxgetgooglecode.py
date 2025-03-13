#!/usr/bin/python3
# -*- coding:utf-8 -*-

import hmac, base64, struct, hashlib, time
import platform

def get_hotp_token(secret, intervals_no):
    key = base64.b32decode(secret, True)
    msg = struct.pack(">Q", intervals_no)
    h = hmac.new(key, msg, hashlib.sha1).digest()
    o = ord(chr(h[19])) & 15
    h = (struct.unpack(">I", h[o:o+4])[0] & 0x7fffffff) % 1000000
    return h

def get_totp_token(secret):
    return get_hotp_token(secret, intervals_no=int(time.time())//30)

def get_google_code():
    """
    :return: googlecode

    """
    secret = "${ SECRET }"
    googlecode = get_hotp_token(secret, intervals_no=int(time.time())//30)
    return '%06d' % googlecode

print(get_google_code())
