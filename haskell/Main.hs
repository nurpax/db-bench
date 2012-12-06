{-# LANGUAGE OverloadedStrings #-}

import           Control.Monad
import           Control.Exception (bracket)
import           Criterion.Config (defaultConfig)
import           Criterion.Main
import           Data.Int
import           Data.List
import qualified Database.MySQL.Simple as MS
import qualified Database.SQLite.Simple as S
import qualified Database.SQLite3 as DS
import           Options.Applicative

import           Util
import qualified Sqlite

main :: IO()
main = do
  putStrLn "*** Benchmark sqlie-simple Database.SQLite.Simple"
  Sqlite.benchSqliteSimple
  putStrLn "*** Benchmark direct-sqlite Database.SQLite3"
  Sqlite.benchDirectSqlite3
