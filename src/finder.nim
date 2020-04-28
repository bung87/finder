
import os, tables, strformat
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
      zipData:PZipSource
      

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
      var err:ptr int32
      var s = p.cstring
      x.zipData = zip_source_buffer_create(cast[pointer]( s.unsafeAddr),len(p).uint64,0,err)
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
    discard
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
  var x:Finder
  x.fType = FinderType.fs2mem
  let p = "./tests"
  initFinder(x,p)
  assert x.tableData.hasKey("config.nims")
  assert x.get("config.nims") == r
  var y:Finder
  y.fType = FinderType.zip
  let p2 = "./tests/Archive.zip"
  initFinder(y,p2)
  assert y.get("config.nims") == r
    