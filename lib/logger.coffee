class Logger

  constructor:(@verbosity=0,@silent=false)->
    @prefix           = {}
    @prefix[@_ERROR]   = "[ERROR]"
    @prefix[@_WARNING] = "[WARNING]"
    @prefix[@_INFO]    = "[INFO]"
    @prefix[@_LOG]     = "[LOG]"
    @prefix[@_DEBUG]   = "[DEBUG]"
    @prefix[@_TRACE]   = "[TRACE]"

  set_verbosity:(v)=>
    @verbosity = v

  set_silent:(s)=>
    @silent = s

  _log:(level,content...)=>
    if not @silent and level <= @verbosity
      console.error @prefix[level], content...

  error:(content...)=>@_log(@_ERROR,content...)
  ERROR:(content...)=>@_log(@_ERROR,content...)

  warning:(content...)=>@_log(@_WARNING,content...)
  WARNING:(content...)=>@_log(@_WARNING,content...)

  info:(content...)=>@_log(@_INFO,content...)
  INFO:(content...)=>@_log(@_INFO,content...)

  log:(content...)=>@_log(@_LOG,content...)
  LOG:(content...)=>@_log(@_LOG,content...)

  debug:(content...)=>@_log(@_DEBUG,content...)
  DEBUG:(content...)=>@_log(@_DEBUG,content...)

  trace:(content...)=>@_log(@_TRACE,content...)
  TRACE:(content...)=>@_log(@_TRACE,content...)

  _ERROR  :  -1
  _WARNING:  0
  _INFO   :  1
  _LOG    :  2
  _DEBUG  :  3
  _TRACE  :  4

exports.Logger = Logger
exports.Logger.INSTANCE = exports.INSTANCE = new Logger()
