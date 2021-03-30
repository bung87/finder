# finder   [![Build Status](travis)](https://travis-ci.org/bung87/finder)  

fs memory zip finder implement in Nim  

note: 
when use MacOS context menu `Compress`  
it will use defalte64 which not compatible with zlib's deflate which not supported by `zippy`  

# compile config  

`switch("d","nimOldCaseObjects")`  

## usage  

``` Nim
const r = "switch(\"path\", \"$projectDir/../src\")"

# fs2mem
var x:Finder
x.fType = FinderType.fs2mem
let p = "./tests"
initFinder(x,p)

assert x.get("config.nims") == r

# zip
var y:Finder
y.fType = FinderType.zip
let p2 = "./tests/Archive.zip"
initFinder(y,p2)
assert y.get("config.nims") == r

# zip2mem
var z:Finder
z.fType = FinderType.zip2mem
const archive = staticRead( currentSourcePath.parentDir() / "../tests/Archive.zip")
initFinder(z,archive)
assert z.get("config.nims") == r

#fs
var g:Finder
g.fType = FinderType.fs
initFinder(g, "./tests")
assert g.get("config.nims") == r
```

[travis]: https://travis-ci.org/bung87/finder.svg?branch=master
