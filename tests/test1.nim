# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

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
  let p2 = getCurrentDir() / "tests" / "Archive.zip"
  initFinder(y,p2)
  check y.get("config.nims") == r
test "zip2mem":
  # zip2mem
  var z:Finder
  z.fType = FinderType.zip2mem
  let archive = readFile( getCurrentDir() / "tests" / "Archive.zip")
  initFinder(z,archive)
  check z.get("config.nims") == r
test "fs":
  #fs
  var g:Finder
  g.fType = FinderType.fs
  initFinder(g, "./tests")
  check g.get("config.nims") == r
