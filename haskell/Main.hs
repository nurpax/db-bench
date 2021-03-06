{-# LANGUAGE OverloadedStrings #-}

import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Monad
import           Criterion.Main
import           Data.Int
import           Data.List
import           Options.Applicative

import qualified Mysql
import qualified Psql
import qualified Sqlite
import qualified Hdbc
import           Util

main :: IO ()
main = do
  Sqlite.benchSqliteSimple
  Sqlite.benchDirectSqlite3
  Mysql.benchMysqlSimple
  Psql.benchPostgresqlSimple
  Hdbc.benchHdbcSqlite3
