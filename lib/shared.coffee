path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
yargs                   = require 'yargs'
Formatter               = require('termstyle').Formatter
LOG                     = require(path.join(LIB_DIR,"logger")).INSTANCE
package_json            = require path.join(HOMEDIR,'package.json')
VERSION                 = package_json.version
NAME                    = package_json['app-name'] ? package_json.name
PUBLISHED               = package_json.published
DESCRIPTION             = package_json.description
Util                    = require('inote-util').Util
# Constants and Utility Functions used in Multiple Files

class Shared

  nad: "" # newline after description - set to a blank string or `\n`
  exe: "document-alchemy"
  doc_alchem_host: "https://documentalchemy.com"
  base_api_path: "/api/v1"
  width: 80
  command_map = null
  command_run = false

  constructor:()->
    @url_base = @doc_alchem_host + @base_api_path
    @formatter = new Formatter()

  parse_config:(config,params)=>
    identity = (x)->x
    normed = {}
    if config?
      for key, value of config
        for name, pattern of params
          xform = identity
          if Array.isArray(pattern)
            xform = pattern[1]
            pattern = pattern[0]
          if pattern.test key
            normed[name] = xform(value)
    return normed

  set_width:(w)=>
    @width = Util.to_int(w) ? 80

  ua:()=>@_ver_str(false,"/")

  wrap:(text)=>
    @formatter.wrap(text,{width:@width,pad_left:2,pad_right:0,combine_multiple_space_chars:false})

  handle_extended_help:(args, map)=>
    map ?= @command_map
    if args.xhelp
      cmd_name = args._[0] ? ""
      cmd = map[cmd_name]
      unless cmd?
        LOG.error "Command '#{cmd_name}' not recognized in 'xhelp'."
        process.exit(1)
      else if cmd.extended_help?
        cmd.extended_help()
        process.exit(0)
      else
        LOG.error "Extended help not availble for command '#{cmd_name}'."
        process.exit(1)

  handle_help_and_version: (argv)=>
    if argv.version
      @show_version()
      process.exit(0)
    else if argv.help
      @show_help()
      process.exit(0)

  show_help:(after_description)=>
    if DESCRIPTION?
      console.log DESCRIPTION
    if after_description?
      console.log after_description
    yargs.showHelp()

  _ver_str:(include_published=true,joinchar=" ")=>
    buf = []
    if NAME?
      buf.push NAME
    if VERSION?
      buf.push "v#{VERSION}"
    if include_published and PUBLISHED?
      buf.push "- #{PUBLISHED}"
    ver = buf.join(joinchar)
    return ver

  show_version:()=>
    console.log @_ver_str()

module.exports = new Shared()
