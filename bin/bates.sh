#!/bin/bash

export BATES_PTH=node_modules/bates
export PATH=$PATH:$(pwd)/node_modules/.bin

DEV_SERVER=$BATES_PTH/src/devServer
TEST=$BATES_PTH/bin/test.sh

if [ $1 = "start" ]; then
  echo "npm prune, npm start"
  parallelshell \
  "node $DEV_SERVER" \
  "onchange src -- $TEST" \
  "npm outdated"
fi
if [ $1 = "test" ]; then
  $TEST
fi
if [ $1 = "server" ]; then
  node $DEV_SERVER
fi
if [ $1 = "clean" ]; then
  rimraf lib dist/**.js
fi
if [ $1 = "lib" ]; then
  NODE_ENV=production
  babel src \
  --presets react,es2015,stage-0 \
  --ignore *.test.js \
  --out-dir lib
fi
if [ $1 = "bundle" ]; then
  NODE_ENV=production
  webpack \
  --config $BATES_PTH/src/webpackBundle
fi
if [ $1 = "dist" ]; then
  NODE_ENV=production
  webpack \
  --config $BATES_PTH/src/webpackDist
fi
if [ $1 = "cov" ]; then
  if [ ! -e .babelrc ]; then
    HAS_BABELRC=false
    echo '{"presets":["react","es2015","stage-0"]}' > .babelrc
  fi
  NODE_ENV=test
  babel-node \
  node_modules/.bin/isparta cover \
  --report text --report lcovonly --report html \
  --include 'src/**/!(*-test).js' \
  node_modules/.bin/_mocha \
  -- -R dot 'src/**/*.test.js'
  open coverage/index.html
  if [ $HAS_BABELRC = "false" ]; then
    rm -rf .babelrc
  fi
fi