path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
log                     = require(path.join(LIB_DIR,"logger")).INSTANCE
Shared                  = require(path.join(LIB_DIR,"shared"))
request                 = require 'request'

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

  _process_get_and_write_response:(argv,options)=>
    @log.debug "GETting:",options
    if argv.out?
      out = fs.createWriteStream(argv.out,'binary')
    else
      out = process.stdout
    req = request.get options
    req.on 'response', (response)=>
      unless /^2[0-9][0-9]$/.test response?.statusCode
        @log.error "Expected 2XX-series status code. Found #{response?.statusCode}."
        if not argv['api-key'] and /^401$/.test response?.statusCode
          @log.error "The 401 (Unauthorized) response is probably because"
          @log.error "you did not supply an API Key."
          @log.error "Use '-a <KEY>' to specify a key on the command line,"
          @log.error "or run '#{@exe} --xhelp' for more information.\n"
        process.exit 1
    req.pipe(out,{encoding:"binary"})

  _process_post_file_and_write_response:(argv,options,file_field,file_path)=>
    @log.debug "POSTing:",options,file_path
    if argv.out?
      out = fs.createWriteStream(argv.out,'binary')
    else
      out = process.stdout
    req = request.post options
    form = req.form()
    form.append(file_field, fs.createReadStream(file_path))
    req.on 'response', (response)=>
      unless /^2[0-9][0-9]$/.test response?.statusCode
        @log.error "Expected 2XX-series status code. Found #{response?.statusCode}."
        if not argv['api-key'] and /^401$/.test response?.statusCode
          @log.error "The 401 (Unauthorized) response is probably because"
          @log.error "you did not supply an API Key."
          @log.error "Use '-a <KEY>' to specify a key on the command line,"
          @log.error "or run '#{@exe} --xhelp' for more information.\n"
        process.exit 1
    req.pipe(out,{encoding:"binary"})

exports.BaseCommand = BaseCommand
