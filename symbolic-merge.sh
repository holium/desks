#!/bin/bash

# tenari@dzs-MacBook-Pro desks % cd urbit/pkg
# tenari@dzs-MacBook-Pro pkg % ../../symbolic-merge.sh base-dev ../../realm/
# call from within pkg/ as ./symbolic-merge.sh source-pkg target-pkg

function link() { # source desk, target desk, filepath
  local src=${3:2}; # strip leading ./
  local pax=$src;
  local rel=$1;
  local bak="urbit";
  while [[ "." != $(dirname "$pax") ]]; do
    pax=$(dirname "$pax");
    bak="../$bak";
  done;
  printf "../$bak/pkg/$rel/$src\n";
  printf "../$2/$src\n\n";
  ln -sf "../$bak/pkg/$rel/$src" "../$2/$src";
}

# mirror directory structure
cd $1;
find . -type d -exec mkdir -p ../$2/{} \;

# symlink all files, overwriting existing ones
export -f link
find . -type f \
       -not -name '*.bill' \
       -not -name '*.kelvin' \
       -exec bash -c "link $1 $2 {}" \;
