#!/bin/bash

echo "==> Updating themes"
git submodule update --recursive --remote &

for theme in themes/*/; do
  printf "${theme%/}\n"
  git -C "$theme" pull &
done

echo "==> Removing docs"
rm -rf docs

for arg in "$@"; do
  case $arg in
  --clear-gen)
    echo "==> Removing resources/_gen"
    rm -rf resources/_gen
    shift
    ;;
  esac
done

echo "==> Running Hugo"
hugo --minify

wait # Wait for submodule pull background task
