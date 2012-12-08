
module Util (
  checksum) where

import Control.Monad (when)

nRows :: Int
nRows = 10000

checksum :: Int -> IO ()
checksum s =
  when (s /= nRows*(nRows+1) `div` 2) $
    error ("Expecting sum of ids to be (1+2+3+..+n) but got " ++ show s)

