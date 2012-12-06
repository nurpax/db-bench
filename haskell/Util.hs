
module Util (
  checksum) where

nRows :: Int
nRows = 10000

checksum :: Int -> IO ()
checksum s =
  if s /= nRows*(nRows+1) `div` 2 then
    error "Expecting sum of ids to be (1+2+3+..+n)"
   else
    return ()

