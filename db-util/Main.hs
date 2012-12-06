{-# LANGUAGE OverloadedStrings #-}

import           Control.Applicative
import           Options.Applicative

import           Types
import qualified Mysql
import qualified Psql
import qualified Sqlite


options :: Parser Opts
options = Opts
       <$> strOption (long "output-db"
                      & metavar "FILE"
                      & help "Output database file or database name")
       <*> strOption (long "db"
                      & metavar "DB"
                      & help "Database implementation (sqlite, psql or mysql)")

main = do
  options <- execParser $
               info (helper <*> options)
               (fullDesc
                & progDesc "Generate test database")
  case dbImpl options of
    "sqlite" -> Sqlite.gen options
    "mysql"  -> Mysql.gen options
    "psql"  -> Psql.gen options
    other    -> error ("uknown database type: "++other)
