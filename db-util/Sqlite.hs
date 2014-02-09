{-# LANGUAGE OverloadedStrings #-}

module Sqlite (
  gen) where

import           Control.Exception (bracket)
import           Database.SQLite.Simple
import qualified Data.Text as T
import           Data.Time (UTCTime)

import           Types

-- NOTE: IF YOU TOUCH THIS HOW THIS FUNCTION OUTPUTS DATA, MAKE SURE
-- YOU MIRROR THE CHANGES FOR Mysql.hs!!

gen' :: Connection -> IO ()
gen' conn = do
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

genUtcTimesTable :: Connection -> IO ()
genUtcTimesTable conn = do
  putStrLn "Generating test database content testdata_utc.."
  execute_ conn "DROP TABLE IF EXISTS testdata_utc"
  execute_ conn "CREATE TABLE testdata_utc (id INTEGER PRIMARY KEY, time TIMESTAMP, ex1_id INTEGER, ex2_id INTEGER)"
  -- Note: begin transaction is here just to speed up inserts
  execute_ conn "BEGIN"
  mapM_ addRow [0..9999]
  execute_ conn "COMMIT"
  where
    addRow ndx = do
      let q = "INSERT INTO testdata_utc (id,time,ex1_id,ex2_id) VALUES (?,?,?,?)"
      execute conn q (ndx+1,
                      times !! (ndx `mod` 4),
                      [0..10 :: Int] !! (ndx `mod` 10),
                      [0..10 :: Int] !! (ndx `mod` 10))

    times :: [UTCTime]
    times = map read [ "2010-10-10 00:00:00"
                     , "2011-11-11 01:30:00"
                     , "2012-12-01 02:34:02"
                     , "2013-01-05 04:34:32"
                     ]

gen :: Opts -> IO ()
gen options =
  bracket (open (outputDb options)) close (\c -> gen' c >> genUtcTimesTable c)
