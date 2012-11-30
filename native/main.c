
#include <sqlite3.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


#define GUARD(stmt, msg) \
    do {                      \
        int err = stmt;       \
        if (err != SQLITE_OK) \
        {                     \
            printf(msg);      \
            exit(1);          \
        }                     \
    } while(0)

static void query(sqlite3* conn)
{
    int ret;
    const int N = 10000;
    long sum = 0;
    sqlite3_stmt* stmt;

    GUARD(sqlite3_prepare_v2(conn, "SELECT id FROM testdata", -1, &stmt, NULL),
          "prepare_v2 failed");

    while((ret = sqlite3_step(stmt)) != SQLITE_DONE)
    {
        if (ret != SQLITE_ROW)
        {
            printf("failed step");
            exit(1);
        }

        sum += sqlite3_column_int(stmt, 0);
    }

    if (sum != N*(N+1)/2)
    {
        printf("expecting select sum to be 1+2+3,..,n");
        exit(1);
    }

    sqlite3_finalize(stmt);
}

int main(void)
{
    int N = 1000;
    int i;
    sqlite3* conn;

    GUARD(sqlite3_open("../test.db", &conn), "open failed");

    printf("performing %d x SELECTs (each returning 10000 rows)\n", N);

    for (i = 0; i < N; i++)
        query(conn);

    sqlite3_close(conn);
    return 0;
}
