{-# LANGUAGE OverloadedStrings #-}

module Mysql (
  gen) where

import           Control.Monad (void)
import           Control.Exception (bracket)
import           Database.MySQL.Simple
import qualified Data.Text as T
import           Data.Time (UTCTime)

import           Types

-- NOTE: THE DATA (SCHEMA AND ROWS) MUST MATCH WITH WHAT Sqlite.hs
-- GENERATES!!

gen' :: Connection -> IO ()
gen' conn = do
  putStrLn "Generating test database content.."
  execute_ conn "DROP TABLE IF EXISTS testdata"
  execute_ conn "CREATE TABLE testdata (id INTEGER PRIMARY KEY, str TEXT, t TIMESTAMP)"
  -- Note: begin transaction is here just to speed up inserts
  mapM_ addRow [0..9999]
  where
    addRow ndx = do
      let q = "INSERT INTO testdata (id,str,t) VALUES (?,?,?)"
      void $ execute conn q (ndx+1, strs !! (ndx `mod` 4), t)

    strs :: [T.Text]
    strs = ["a", "ab", "abc", "abcd"]

    t :: UTCTime
    t = read "2010-10-10 00:00:00"


gen :: Opts -> IO ()
gen options =
  bracket (connect defaultConnectInfo { connectDatabase = outputDb options }) close gen'
