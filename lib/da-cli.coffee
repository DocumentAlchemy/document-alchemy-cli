path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
Util                    = require('inote-util').Util
FileUtil                = require('inote-util').FileUtil
ObjectUtil              = require('inote-util').ObjectUtil
yargs                   = require 'yargs'
request                 = require 'request'

CONFIG_FILE_NAME        = ".documentalchemycli.json"
USER_HOMEDIR            = require('os-homedir')()
HOMEDIR_CONFIG_FILE     = path.join(USER_HOMEDIR,CONFIG_FILE_NAME)
CWD                     = process.cwd()
CWD_CONFIG_FILE         = path.join(CWD,CONFIG_FILE_NAME)

COMMAND_DIR             = path.join(LIB_DIR,'commands')

DEFAULT_DOC_ALCHEM_HOST = "https://documentalchemy.com"
DEFAULT_BASE_API_PATH   = "/api/v1"
LOG                     = require(path.join(LIB_DIR,"logger")).INSTANCE
Shared                  = require(path.join(LIB_DIR,"shared"))
NAD                     = Shared.nad
EXE                     = Shared.exe
URL_BASE                = Shared.url_base

class DaCli

  constructor:(@config_file_list)->
    @config_file_list ?= [ HOMEDIR_CONFIG_FILE, CWD_CONFIG_FILE ]
    @config = {}

  @main:()=>
    cli = new DaCli()
    cli.initialize process.argv, ()=>
      LOG.trace "CLI initialized."

  initialize:(args,callback)=>
    if typeof args is 'function' and not callback?
      callback = args
      args = null
    @_list_commands (err,clist)=>
      if err?
        callback(err)
      else
        [command_list, command_map] = @_load_commands clist
        command_map ?= {}
        command_map[""] = {extended_help:@extended_help}
        Shared.command_map = command_map
        for command in command_list
          if command.config_params?
            @_config_params = ObjectUtil.merge @_config_params, command.config_params
        @_load_config @config_file_list, (err,config,warnings)=>
          @config = config
          @argv  = @_init_yargs config, args, command_list
          LOG.set_verbosity @argv.verbose
          LOG.set_silent @argv.quiet
          Shared.set_width @config.wide
          if warnings?.length > 0
            for warning in warnings
              LOG.warning warning
          if not @argv["api-key"]? and not @argv.help and not @argv.version
            console.error ""
            LOG.warning "No API Key value was set. This is likely to lead to an error."
            LOG.warning "Be sure to pass '-a <KEY>', or run"
            LOG.warning "'#{EXE} --xhelp' for more information.\n"
          unless Shared.command_run
            @argv.help = true
          Shared.handle_extended_help @argv, command_map
          Shared.handle_help_and_version @argv
          callback()

  _init_yargs:(config, args, commands)=>
    if Array.isArray(config) and not args?
      args = config
      config = null
    config ?= @config ? {}
    args ?= process.argv
    commands ?= []
    yargs.parse(args)
    if typeof config.wide is 'number'
      yargs.wrap(config.wide)
    else if config.wide
      yargs.wrap(yargs.terminalWidth())
    yargs.usage("Usage: #{EXE} [OPTIONS] <COMMAND> [OPTIONS]")
    yargs.example("#{EXE} --xhelp","show extended help")
    yargs.example("#{EXE} <CMD> --help","show help for the command <CMD>")
    yargs.example("#{EXE} <CMD> --xhelp","show extended help for the command <CMD>")
    yargs.option "a",       { global:true, group:"Common Parameters", alias:"api-key", type:"string", requiresArg:true, default:config["api-key"],         describe:"DocumentAlchemy API key#{NAD}"         }
    yargs.option "o",       { global:true, group:"Common Parameters", alias:"out",     type:"string", requiresArg:true, default:config["out"],             describe:"file to write to; when absent or '-', stdout is used#{NAD}" }
    yargs.option "s",       { global:true, group:"Common Parameters", alias:"store",   boolean:true,                    default:(config["store"] ? false), describe:"when true, save the generated document on the server#{NAD}" }
    yargs.option "t",       { global:true, group:"Common Parameters", alias:"ttl",     number:true,   requiresArg:true, default:config["ttl"],             describe:"time-to-live for the stored image, ignored when --store is false#{NAD}" }
    yargs.option "p",       { global:true, group:"Common Parameters", alias:"param",   type:"string", requiresArg:true, nargs:2,                           describe:"extra name value pair to be passed with the REST call#{NAD}" }
    yargs.option "?",       { global:true, group:"Help & Other Meta-Parameters", alias:"help",    boolean:true,                                                       describe:"show help; may also be used following a command name to get command-specific help#{NAD}" }
    yargs.option "x",       { global:true, group:"Help & Other Meta-Parameters", alias:"xhelp",   boolean:true,                                                       describe:"show detailed help; may also be used following a command name to get extended help on the given command#{NAD}" }
    yargs.option "version", { global:true, group:"Help & Other Meta-Parameters",                  boolean:true,                                                       describe:"show version information#{NAD}" }
    yargs.option "v",       { global:true, group:"Help & Other Meta-Parameters", alias:"verbose", count:true,                      default:config["verbose"],         describe:"be more chatty; can be repeated up to 4 times for more detail.#{NAD}" }
    yargs.option "quiet",   { global:true, group:"Help & Other Meta-Parameters",                  boolean:true,                    default:(config["quiet"] ? false), describe:"be less chatty#{NAD}"                  }
    for command in commands
      yargs.command command.make_command(config)
    # yargs.strict()
    argv = yargs.argv
    if argv.o in ['-','']
      argv.o = argv.out = null
    return argv

  _load_config:(list,callback)=>
    config = {}
    warnings = [] # queue up warnings until we've parsed the config for -v and -q
    action = (file,index,list,next)=>
      fs.exists file, (exists)=>
        if exists
          c = null
          try
            c = FileUtil.load_json_file_sync(file)
          catch err
            warnings.push "Configuration file at #{HOMEDIR_CONFIG_FILE} could not be parsed as valid JSON document."
          config = ObjectUtil.merge(config,@_norm_config(c))
        next()
    Util.for_each_async list, action, ()=>
      callback(null, config,warnings)

  _config_params: {
    "api-key" :/^(da[-_\.])?(api[-_\.]?)?key$/i
    "ttl"     :[/^((ttl)|(time[-_\.]?to[-_\.]?live))$/i, Util.to_int]
    "store"   :[/^store$/i, Util.truthy_string]
    "quiet"   :[/^q(uiet)?$/i, Util.truthy_string]
    "verbose" :[/^v(erbose)?$/i, (v)->(Util.to_int(v) ? (if Util.truthy_string(v) then 1 else 0))]
    "wide"    :[/^wide$/i, (v)->(Util.to_int(v) ? Util.truthy_string(v))]
    "out"     :[/^o(ut)$/i, (v)->(if v in ['-',''] then null else v)]
  }

  _norm_config:(config)=>
    config = Shared.parse_config config, @_config_params
    config.capture ?= {}
    return config

  _list_commands:(command_dir,callback)=>
    if typeof command_dir is 'function' and not callback?
      callback = command_dir
      command_dir = null
    command_dir ?= COMMAND_DIR
    commands = []
    fs.readdir command_dir, (err,files)=>
      if err?
        callback(err)
      else
        for file in files
          match = file.match /^([a-z].*)\.((coffee)|(js))$/
          if match?[1]?
            commands.push match[1]
      callback(null,commands)

  _load_commands:(list)=>
    cmd_list = []
    cmd_map = {}
    for name in list
      cmd = require(path.join(LIB_DIR,"commands",name))
      cmd_list.push(cmd)
      cmd_map[name] = cmd
    return [cmd_list,cmd_map]

  extended_help: ()=>
    Shared.show_help()
    console.log "\nABOUT THIS APPLICATION\n"
    console.log Shared.wrap """
      #{EXE} is a command-line interface to the DocumentAlchemy API. Using #{EXE} you can easily invoke a number of document processing methods directly from the command line.

      PLEASE NOTE: Before using this program you will need a DocumentAlchemy API key. If you don't have one, you can get one immediately and for free by signing up for DocumentAlchemy at <https://documentalchemy.com/>. Once you've signed up you'll find your API key by selecting "My API Keys" under your "account" menu in the menu bar.

      In the interim you can also use this temporary API Key: 'dO6M2p9sKRMGQYub'.

      As an example, one simple DocumentAlchemy API method will generate a QR code.  To invoke that REST method from the command line using #{EXE}, you may enter an command like the following:

      #{EXE} qrcode "Hello World!" -o qr-hello.png -a dO6M2p9sKRMGQYub

      This will generate a file named `qr-hello.png` that contains an image of a QR code encoding the text "Hello World!".

    """
    console.log "\nCONFIGURATION\n"
    console.log Shared.wrap """
      You may set "persistent" command-line parameters by creating a configuration file.

      The file must be named '.documentalchemycli.json'.

      #{EXE} will look for a configuration file in two places: 1) the current working directory and 2) the user's 'HOME' directory.

      If a file is found in both places they will be COMBINED to set the overall execution context.  Values set in the current working directory's configuration file will override those found in the home-directory's configuration file.

      Both configuration files define "default" values.  Any parameters passed on the command line will override those found in a configuration file.

      For example, to set a persistent value for the API Key (so you do not need to pass it on the command line every time), you can create a JSON document such as:

      { "api-key":"dO6M2p9sKRMGQYub" }

      and save it as '.documentalchemycli.json' in your home directory.

      To set command-specific parameters, place them in a map under the name of the command.  For instance, the 'qrcode' command supports a `size` parameter which controls the size of the generate image (in pixels).  To set this value in the configuration file, you may use:

      { "api-key":"dO6M2p9sKRMGQYub", "qrcode": { "size":280 } }

      Now you may invoke the QR code method via:

      #{EXE} qrcode "Hello World!" -o qr-hello.png

      which will generate a 280-by-280 pixel image.

      Note that '.documentalchemycli.json' is parsed as a true JSON file--comments and other JavaScript-style code is not allowed.

    """
    console.log "\nCOMMON PARAMETERS\n"
    console.log Shared.wrap """
      There are a handful of command-line arguments that are shared by all commands. These are enumerated below.

        -a --api-key - DocumentAlchemy API key to be submitted with the request.
                       Example: -a dO6M2p9sKRMGQYub

        -o --out     - File to write response to.  When missing or '-', the
                       response document is written to stdout instead.
                       Example: -o foo.pdf

        -s --store   - When used, rather than returning the generated document,
                       the document will be stored in the server's (temporary)
                       file store.  In this case a JSON document containing a
                       identifier ('id') and a URL for the stored file ('href')
                       will be returned instead.
                       Example: --store
                       Example: --no-store

        -t --ttl     - When 'store' is set, this parameter specifies the duration
                       (in seconds) that the document should be stored for.
                       The default is 3600 (one hour). The maximum value is
                       86400 (one day).
                       Example: -t 14400

        -p --param   - This argument specifies an "extra" query string or request
                       body parameter to send to the underlying REST method with
                       the rest of the request. This is useful when you'd like to
                       set a parameter that is not otherwise exposed in the CLI.
                       This argument must be followed by TWO values.  '--param'
                       may be repeated more than once to set more than one value.
                       Example: -p name1 value1 -p "name two" "value two"

    """
    console.log "\nABOUT DOCUMENT ALCHEMY\n"
    console.log Shared.wrap """
      Document Alchemy provides a RESTful web-service API for generating, transforming, converting and processing documents in various formats, including:

       - MS Office documents such as Microsoft Word, Excel and PowerPoint.
       - Open source office documents such Apache OpenOffice files.
       - Adobe's Portable Document Format (PDF).
       - HTML, Markdown and other text formats.
      - Images such as PNG, JPEG, GIF and others.

      More information, free, online document conversion tools and interactive documentation of our document processing API can be found at <https://documentalchemy.com>.

      You can follow us on Twitter at <@DocumentAlchemy>.

      If you have any questions, comments or feedback for us, you can reach us via our online contact form at <https://documentalchemy.com/contact-us> or via the email addresses listed on that page.

    """
    console.log "\nTHIS APPLICATION IS OPEN SOURCE SOFTWARE\n"
    console.log Shared.wrap """
      The source code and documentation for #{EXE} is available for you to learn from, modify or extend.

      It is made available under an MIT-style license.

      You'll find it at <https://github.com/documentalchemy/document-alchemy-cli>.

      We welcome your questions, comments, feedback or pull requests.

    """
if require.main is module
  DaCli.main()
