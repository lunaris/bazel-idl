#!/bin/bash

source $1

MODULE=$2

cat <<EOF
module $MODULE where

$IMPORTS

data $RECORD_TYPE
  = $RECORD_TYPE
      { id   :: $ID_TYPE
      , name :: $NAME_TYPE
      }

  deriving (Eq, Show)
EOF
