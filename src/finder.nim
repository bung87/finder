
import os, tables, strformat
import zippy/ziparchives,streams
export ziparchives

type FinderType* {.pure.} = enum
  fs,
  fs2mem,
  zip2mem,
  zip

type Finder* = object
  case fType*:FinderType
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
        assets[key] = val
      x.tableData = assets
    
    elif x.fType == FinderType.zip2mem:
      # read from memory zip
      var zip = new ZipArchive
      zip.open(cast[seq[uint8]](arg))
      x.zipData = zip.addr
    elif x.fType == FinderType.zip:
      # read from file system zip
      let p = arg.expandTilde.absolutePath
      var zip = new ZipArchive
      zip.open(p)
      x.zipFile = zip.addr
    elif x.fType == FinderType.fs:
      let p = arg.expandTilde.absolutePath
      x.base = p

proc get*(x:Finder,path:string):string =
  if x.fType == FinderType.fs2mem:
      result = x.tableData[path] 
  elif x.fType == FinderType.zip2mem:
    # read from memory zip
    result = x.zipData[].contents[path].contents
  elif x.fType == FinderType.zip:
    # read from file system zip
    result = x.zipFile[].contents[path].contents
  elif x.fType == FinderType.fs:
    let p = absolutePath(path,x.base)
    result = readFile(p)

