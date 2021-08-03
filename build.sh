#!/bin/bash

echo "==> Updating themes"
git submodule update --recursive --remote &

for theme in themes/*/; do
  printf "${theme%/}\n"
  git -C "$theme" pull &
done

echo "==> Clearing docs/"
rm -rf docs

# echo "==> Clearing resources/_gen"
# rm -rf resources/_gen

echo "==> Running Hugo"
hugo

wait
