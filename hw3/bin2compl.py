def dec2com(num, N = None):
    res = ''
    L = len(bin(abs(num))[2:])
    MSB = 1 << (L+1)
    if (num >= 0):
        res = bin(MSB + num)[3:]
    else:
        res = bin(MSB + abs(num))[3:].replace('1','x').replace('0','1').replace('x','0')
        nI = int(res,2) + 1
        res = bin(nI)[2:]
    if res[:2] in ['11', '00']:
        res = res[1:]
    if N != None:
        while len(res) < N:
            res = res[0] + res
        res = res[-N:]
    return res

def com2dec(num):
    res = 0
    L = len(num)
    if num[0] == '1':
        res = -(1 << (L-1))
    for i in range(1, L):
        if num[i] == '1':
            res += 1 << (L-1-i)
    return res
