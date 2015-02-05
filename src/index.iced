
fs = require 'fs'
tty = require 'tty'
{make_esc} = require 'iced-error'

#=======================================================

class TtyLookup 

  constructor : ({@fd}) ->
    @fd or= 0

  #-------------

  assert_tty : (cb) ->
    err = null
    if not tty.isatty @fd
      err = new Error "stdin is not a tty"
    cb err

  #-------------

  os_check : (cb) ->
    err = null
    unless process in [ 'darwin', 'linux' ]
      err = new Error "can only run on Linux and OSX"
    cb err

  #-------------

  list_ttys : (cb) ->
    esc = make_esc cb, "TtyLookup.list_ttys"
    await @list_ttys_in "/dev", /^tty[A-Za-z0-9]$/, esc defer()
    await @list_ttys_in "/dev/pts", /^[0-9]+$/, esc defer()
    cb null

  #-------------

  run : (cb) ->
    esc = make_esc cb, "TtyLookup.run"
    await @assert_tty esc defer()
    await @os_check esc defer()
    await @list_ttys esc defer()
    await @match_our_tty esc defer res
    cb null, res

#=======================================================

exports.tty = (cb) -> (new TtyLookup).run cb

#=======================================================

