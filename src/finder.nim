
import os, tables, strformat, base64, ospaths
import zip/zipfiles

type FinderType {.pure.} = enum
  fs,
  fs2mem,
  zip2mem,
  zip

type Finder = object
  case fType:FinderType
    of FinderType.fs:
      base:string
    of FinderType.zip:
      zipFile:ZipArchive
    of FinderType.fs2mem:
      tableData:Table[string,string]
    of FinderType.zip2mem:
      zipData:string
      

template initFinder(x:typed,arg:typed) =
  block:
    let isFile =  if p.existsFile: true else : false 
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
      x.zipData = readFile p
    elif x.fType == FinderType.zip:
      # read from file system zip
      var zip:ZipArchive
      let openSuccess  = zip.open(p,fmRead)
      x.zipFile = zip

when isMainModule:
  var x:Finder
  x.fType = FinderType.fs2mem
  let p = "./tests"
  initFinder(x,p)
  echo  x.tableData