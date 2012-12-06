
module Types (
  Opts(..)) where

data Opts = Opts
  { outputDb :: String
  , dbImpl :: String
  }

