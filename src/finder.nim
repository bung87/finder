
import os, tables, strformat, base64, ospaths
import zip/zipfiles

type FinderDestType {.pure.}= enum
  fs,memory

type FinderSourceType {.pure.}= enum
  fs,zip

type Finder = object
  case dType:FinderDestType
    of FinderDestType.fs: 
      case sType:FinderSourceType
        of FinderSourceType.fs:
          indexes:Table[string,string] # store relpath -> abspath
        of FinderSourceType.zip:
          zipFile:ZipArchive
    of FinderDestType.memory:
      case sType:FinderSourceType
        of FinderSourceType.fs:
          tableData:Table[string,string]
        of FinderSourceType.zip:
          zipData:string
      

template initFinder(x:typed,arg:typed) =
  block:
    let isFile =  if p.existsFile: true else : false 
    if x.dType == FinderDestType.memory and not isFile:
      # read dir from memory
      x.sType = FinderSourceType.fs
      var assets = initTable[string, string]()
      var key, val: string
      let p = arg.expandTilde.absolutePath
      for path in p.walkDirRec():
        key = path.relativePath(p)
        val = readFile(path)
        assets.add(key, val)
      x.tableData = assets
    
    elif x.dType == FinderDestType.memory and isFile:
      # read from memory zip
      x.sType = FinderSourceType.zip
      x.data = readFile p
    elif x.dType == FinderDestType.fs and isFile:
      # read from file system zip
      x.sType = FinderSourceType.zip
      x.data = readFile p

when isMainModule:
  var x:Finder
  x.dType = FinderDestType.memory
  # const p = "/Users/bung/nim_works/finder/tests"
  let p = "./tests"
  initFinder(x,p)
  echo  x.tableData