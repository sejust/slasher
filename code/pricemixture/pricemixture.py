#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys

total, over = 200, 5
result = []


def iter(total, prices, picked):
    if total < over or len(prices) == 0:
        return

    item = prices[0]
    price = int(item.split(b' ', 1)[0])
    if abs(total - price) <= over:
        result.append((total-price, picked + (item,)))

    iter(total, prices[1:], picked)
    iter(total-price, prices[1:], picked + (item,))


if __name__ == "__main__":

    if len(sys.argv) > 2:
        total, over = int(sys.argv[1]), int(sys.argv[2])
    elif len(sys.argv) > 1:
        total = int(sys.argv[1])

    prices = []
    picked = ()
    with open('price.txt', 'rb') as f:
        for line in f:
            if line.startswith(b'#'):
                continue
            if line.startswith(b'$'):
                line = line.strip(b'$').strip()
                price, name = line.split(b' ', 1)
                total -= int(price)
                picked += (line,)
                continue
            prices.append(line.strip())

    prices.sort(key=lambda x: int(x.split(' ', 1)[0]))
    iter(total, prices[:], picked)

    result.sort(reverse=True)
    with open('result.txt', 'wb') as f:
        for r in result:
            f.write(str(r[0]) + ":\n")
            for item in r[1]:
                f.write("    " + item + "\n")
