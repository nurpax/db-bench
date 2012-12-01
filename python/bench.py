
import sqlite3
import sys

def main():
    N = 10000
    ITERS = 1000
    conn = sqlite3.connect("../test.db")

    c = conn.cursor()

    for i in range(0, ITERS):
        c.execute("SELECT id FROM testdata")
        rows = c.fetchall()

        sum = 0
        for r in rows:
            sum += r[0]

        if sum != N*(N+1)/2:
            print "Wrong results from select"
            exit(1)

    conn.close()
    return 0

if __name__ == "__main__":
  sys.exit(main())
