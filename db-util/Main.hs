{-# LANGUAGE OverloadedStrings #-}

import           Control.Applicative
import           Control.Exception (bracket)
import qualified Data.Text as T
import           Data.Time (UTCTime)
import           Database.SQLite.Simple
import           Options.Applicative

data Opts = Opts
  { outputDb :: String
  }


options :: Parser Opts
options = Opts
       <$> strOption (long "output-db"
                      & metavar "FILE"
                      & help "Output database file")

gen :: Connection -> IO ()
gen conn = do
  putStrLn "Generating test database content.."
  execute_ conn "DROP TABLE IF EXISTS testdata"
  execute_ conn "CREATE TABLE testdata (id INTEGER PRIMARY KEY, str TEXT, t TIMESTAMP)"
  -- Note: begin transaction is here just to speed up inserts
  execute_ conn "BEGIN"
  mapM_ addRow [0..9999]
  execute_ conn "COMMIT"
  where
    addRow ndx = do
      let q = "INSERT INTO testdata (id,str,t) VALUES (?,?,?)"
      execute conn q (ndx+1, strs !! (ndx `mod` 4), t)

    strs :: [T.Text]
    strs = ["a", "ab", "abc", "abcd"]

    t :: UTCTime
    t = read "2010-10-10 00:00:00"

main = do
  options <- execParser $
               info (helper <*> options)
               (fullDesc
                & progDesc "Generate test database")
  bracket (open (outputDb options)) close gen
