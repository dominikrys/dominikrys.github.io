#!/bin/bash

echo "==> Updating themes"
git submodule update --recursive --remote &

for theme in themes/*/; do
  printf "${theme%/}\n"
  git -C "$theme" pull &
done

echo "==> Clearing docs/"
rm -rf docs

for arg in "$@"; do
  case $arg in
  --clear-gen)
    echo "==> Clearing resources/_gen"
    rm -rf resources/_gen
    shift
    ;;
  esac
done

echo "==> Running Hugo"
hugo

wait
