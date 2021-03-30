# zipfile.zip archived through 
# `zip zipfile tests/Archive/config.nims tests/Archive/test1.nim -j`
# when use MacOS context menu `Compress` 
# it will use defalte64 which not compatible with zlib's deflate
import unittest,os

import finder
const r = "switch(\"path\", \"$projectDir/../src\")"
test "fs2mem":
  # fs2mem
  var x:Finder
  x.fType = FinderType.fs2mem
  let p = "./tests"
  initFinder(x,p)
  check x.get("config.nims") == r
test "zip":
  # zip
  var y:Finder
  y.fType = FinderType.zip
  let p2 = getCurrentDir() / "tests" / "zipfile.zip"
  initFinder(y,p2)
  check y.get("config.nims") == r
test "zip2mem":
  # zip2mem
  var z:Finder
  z.fType = FinderType.zip2mem
  let archive = readFile( getCurrentDir() / "tests" / "zipfile.zip")
  initFinder(z,archive)
  check z.get("config.nims") == r
test "fs":
  #fs
  var g:Finder
  g.fType = FinderType.fs
  initFinder(g, "./tests")
  check g.get("config.nims") == r
