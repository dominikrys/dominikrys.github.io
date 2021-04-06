#!/bin/bash

echo "==> Clearing docs directory"
rm -rf docs

echo "==> Running Hugo"
hugo
