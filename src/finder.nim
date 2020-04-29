
import os, tables, strformat,sequtils
import zip/[zipfiles,libzip],streams

type FinderType* {.pure.} = enum
  fs,
  fs2mem,
  zip2mem,
  zip

type Finder* = object
  case fType:FinderType
    of FinderType.fs:
      base:string
    of FinderType.zip:
      zipFile:ptr ZipArchive
    of FinderType.fs2mem:
      tableData:Table[string,string]
    of FinderType.zip2mem:
      zipData:ptr ZipArchive
      

template initFinder*(x:typed,arg:typed) =
  block:
    if x.fType == FinderType.fs2mem:
      # read dir from memory
      var assets = initTable[string, string]()
      var key, val: string
      let p = arg.expandTilde.absolutePath
      for path in p.walkDirRec():
        key = path.relativePath(p)
        val = readFile(path)
        assets.add(key, val)
      x.tableData = assets
    
    elif x.fType == FinderType.zip2mem:
      # read from memory zip
      # var s = toSeq(arg.items)
      var zip:ZipArchive
      zip.fromBuffer(arg)
      x.zipData = zip.addr
    elif x.fType == FinderType.zip:
      # read from file system zip
      let p = arg.expandTilde.absolutePath
      var zip:ZipArchive
      let openSuccess  = zip.open(p,fmRead)
      if not openSuccess:
        raise newException(OSError,fmt"can't open {p}")
      x.zipFile = zip.addr
    elif x.fType == FinderType.fs:
      let p = arg.expandTilde.absolutePath
      x.base = p

proc get*(x:Finder,path:string):string =
  if x.fType == FinderType.fs2mem:
      result = x.tableData[path] 
  elif x.fType == FinderType.zip2mem:
    # read from memory zip
    var s = newStringStream()
    x.zipData[].extractFile(path,s)
    result = s.data
  elif x.fType == FinderType.zip:
    # read from file system zip
    var s = newStringStream()
    x.zipFile[].extractFile(path,s)
    result = s.data
  elif x.fType == FinderType.fs:
    let p = absolutePath(path,x.base)
    result = readFile(p)

when isMainModule:
  const r = "switch(\"path\", \"$projectDir/../src\")"

  # fs2mem
  var x:Finder
  x.fType = FinderType.fs2mem
  let p = "./tests"
  initFinder(x,p)
  assert x.tableData.hasKey("config.nims")
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