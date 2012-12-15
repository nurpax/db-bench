
from sqlalchemy import *

N = 10000
ITERS = 1000

db = create_engine('sqlite:///../test.db')

db.echo = False  # Try changing this to True and see what happens

for i in range(0, ITERS):
    rs = db.execute('SELECT id from testdata')
    sum = 0
    for r in rs.fetchall():
        (id,) = r
        sum += int(id)

    if sum != N*(N+1)/2:
        print "Wrong results from select"
        exit(1)
