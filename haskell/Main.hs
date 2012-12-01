{-# LANGUAGE OverloadedStrings #-}

import Control.Exception (bracket)
import Database.SQLite.Simple
import Criterion.Main

import Data.List

selectInts :: Connection -> IO ()
selectInts conn = do
  let n = 10000
  rows <- query_ conn "SELECT id FROM testdata" :: IO [(Only Int)]
  if foldl' (\acc (Only v) -> v + acc) 0 rows /= n*(n+1) `div` 2 then
    error "Expecting sum of ids to be (1+2+3+..+n)"
   else
    return ()

main :: IO()
main = do
  bracket (open "test.db") close go
  where
    go conn =
      defaultMain [bench "SELECT Ints" $ selectInts conn]
