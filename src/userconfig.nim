import os
import strutils
import tables

type ConfigDir* = object
  path*: string

proc initConfigDir*(path: string; autoCreate = true): ConfigDir =
  result.path = joinPath(getConfigDir(), path)
  if autoCreate:
    discard existsOrCreateDir(result.path)

proc getPath*(c: ConfigDir; pieces: varargs[string]): string =
  os.joinPath(c.path, os.joinPath(pieces))

proc initSubdir*(c: ConfigDir; name: string): bool {.discardable.} =
  existsOrCreateDir(c.getPath(name))

proc openFile(c: ConfigDir; filename: string; mode = fmRead): File =
  let path = c.getPath(filename)
  return open(path, mode)

proc createFile*(c: ConfigDir; filename: string) =
  discard c.openFile(filename, fmAppend)

# list #

proc loadList*(c: ConfigDir; filename: string): seq[string] =
  let file = c.openFile(filename)
  while not file.endOfFile:
    result.add(file.readLine())
  file.close()

proc setList*(c: ConfigDir; filename: string; list: seq[string]) =
  let file = c.openFile(filename, fmWrite)
  for item in list:
    file.writeLine(item)
  file.close()

# table #

proc loadTable*(c: ConfigDir; filename: string): Table[string, string] =
  let file = c.openFile(filename)
  while not file.endOfFile:
    let line = file.readLine()
    let spl = line.split("=", 1)
    result[spl[0]] = spl[1]
  file.close()

proc setTable*(c: ConfigDir; filename: string; table: Table[string, string]) =
  let file = c.openFile(filename, fmWrite)
  for k, v in table:
    file.writeLine(k & "=" & v)
  file.close()
