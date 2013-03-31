Haskell database benchmark
==========================

A simple benchmark for comparing Haskell *-simple database binding
libraries
(e.g. [sqlite-simple](https://github.com/nurpax/sqlite-simple/)) to
native C sqlite and Python sqlite.  For the purpose of this benchmark,
the C implementation of the same benchmark is considered the fastest
possible, which gives us a good comparison point for Haskell
performance tuning.

See [results tracker](https://docs.google.com/spreadsheet/ccc?key=0Agg4z8zh_X0idFhvTkNTdnBsTk1iVXJfZU9UZ25BT1E).

## Running the benchmark

Compile:

```
cd db-bench
cabal-dev configure
cabal-dev install
# Create test data for sqlite:
./cabal-dev/bin/db-util --output-db=test.db --db=sqlite
# Similarly for other db's ..., choose --db=mysql or --db=psql
```

Run the benchmark:

```
./cabal-dev/bin/bench
```

