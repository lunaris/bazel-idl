module Test where

import qualified Accounts as A
import qualified Profiles as P

data Test
  = Test
      { testAccount :: A.Account
      , testProfile :: P.Profile
      }

  deriving (Eq, Show)
