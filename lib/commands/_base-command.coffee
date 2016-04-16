path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
log                     = require(path.join(LIB_DIR,"logger")).INSTANCE
Shared                  = require(path.join(LIB_DIR,"shared"))

class BaseCommand

  # To extend this class, implement these methods
  config_params:null
  _command:()=>undefined
  _describe:()=>undefined
  _make_builder:(config)=>((subargs)->undefined)
  _handler:(argv)=>undefined
  _extended_help:()=>undefined

  make_command:(config)=>
    cmd = {}
    cmd.command  = @_command()
    cmd.describe = @_describe()
    cmd.builder  = @_make_builder(config)
    cmd.handler  = (argv)=>
      Shared.command_run = true
      process.nextTick ()=>
        @_handler(argv)
    return cmd

  extended_help:()=>
    Shared.show_help("#{@_command()} - #{@_describe()}")
    @_extended_help()

  _arg_check:(argv)=>
    Shared.handle_extended_help argv
    Shared.handle_help_and_version argv
    return true

  exe:Shared.exe
  url_base:Shared.url_base
  nad:Shared.nad
  log:log

exports.BaseCommand = BaseCommand
