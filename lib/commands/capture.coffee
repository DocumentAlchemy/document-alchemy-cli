yargs                   = require 'yargs'
path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
Util                    = require('inote-util').Util
request                 = require 'request'
LOG                     = require(path.join(LIB_DIR,"logger")).INSTANCE
Shared                  = require(path.join(LIB_DIR,"shared"))
NAD                     = Shared.nad
EXE                     = Shared.exe
URL_BASE                = Shared.url_base

module.exports = {

  extended_help: ()=>
    console.log ""
    Shared.show_help()
    console.log "\nABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'capture' command generates a screenshot of a web page invoking the '/document/-/rendition/{FORMAT}' endpoint.

    By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "A SIMPLE EXAMPLE\n"
    console.log Shared.wrap """
    > #{EXE} capture https://documentalchemy.com/ -o capture.png -a dO6M2p9sKRMGQYub

    where:
    - 'https://documentalchemy.com/' is the URL to capture
    - 'capture.png' is the file to save the generated image to, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

    """

  config_params: {
    "capture": [
      /^capture$/i
      ((v)=>
        return Shared.parse_config v, {
          "bw" :[/^b(rowser)?[-_\.]?w(idth)?$/i, Util.to_int]
          "bh" :[/^b(rowser)?[-_\.]?h(eight)?$/i, Util.to_int]
          "iw" :[/^i(mage)?[-_\.]?w(idth)?$/i, Util.to_int]
          "ih" :[/^i(mage)?[-_\.]?h(eight)?$/i, Util.to_int]
          "ei" :[/^e(nlarge)?([-_\.]?i(mage)?)?$/i, Util.truthy_string]
          "R"  :/^(heade)?r$/i
        }
      )
    ]
  }

  make_command: (config)->
    cmd = {}
    cmd.command  =  "capture <URL>"
    cmd.describe = "capture a screenshot"
    cmd.builder  = (subargs)=>
      subargs.options {
        "f": { group:"Command-Specific Parameters", alias:"format",                choices:["png","jpg"], requiresArg:true,  default:(config.capture["format"] ? "png"), describe:"type of image file to create#{NAD}"                     }
        "w": { group:"Command-Specific Parameters", alias:["bw","browser-width"],  number:true,           requiresArg:true,  default:(config.capture["bw"] ? 1024),      describe:"width of the browser's \"viewport\", in pixels#{NAD}"   }
        "h": { group:"Command-Specific Parameters", alias:["bh","browser-height"], number:true,           requiresArg:true,  default:config.capture["bh"],               describe:"height of the browser's \"viewport\", in pixels#{NAD}"  }
        "W": { group:"Command-Specific Parameters", alias:["iw","image-width"],    number:true,           requiresArg:true,  default:config.capture["iw"],               describe:"width of the generated image, in pixels#{NAD}"          }
        "H": { group:"Command-Specific Parameters", alias:["ih","image-height"],   number:true,           requiresArg:true,  default:config.capture["ih"],               describe:"height of the generated image, in pixels#{NAD}"         }
        "E": { group:"Command-Specific Parameters", alias:["ei","enlarge"],        boolean:true,          requiresArg:false, default:(config.capture["ei"] ? false),     describe:"when false, the source image will not be enlarged if it already fits in the specified image width and height.#{NAD}" }
        "R": { group:"Command-Specific Parameters", alias:["header"],              type:"string",         requiresArg:true,  default:config.capture["header"],           describe:"HTTP header to include in the request in the form \"name: value\"; may be repeated.#{NAD}" }
      }
      subargs.usage("Usage: #{EXE} [OPTIONS] capture <URL> [OPTIONS]")
      subargs.example("#{EXE} capture https://example.com/","#{NAD}capture a screenshot of https://example.com at the default size and resolution, piping result to STDOUT")
      subargs.example("#{EXE} capture https://example.com/ -o eg.png","#{NAD}capture a screenshot of https://example.com at the default size and resolution and save result to eg.png")
      subargs.check (argv)=>
        Shared.handle_extended_help argv
        Shared.handle_help_and_version argv
        if argv._[0] is 'capture'
          url = argv._[1]
          unless /^https?:\/\//.test url
            throw new Error("<URL> parameter must start with 'http://' or 'https://'. Found '#{url}'.")
        return true
    cmd.handler = (argv)=>
      Shared.command_run = true
      process.nextTick ()=>
        LOG.info "Capturing #{argv.f} screenshot of #{argv.URL}..."
        options = {
          url: "#{URL_BASE}/document/-/rendition/#{argv.f}"
          qs: { url: argv.URL }
          headers: { "User-Agent":Shared.ua() }
        }
        if argv['api-key']?
          options.headers.Authorization = "da.key=#{argv['api-key']}"
        for n in ['bw','bh','iw','ih','ei','ttl','store']
          if argv[n]?
            options.qs[n] = argv[n]
        if argv.out?
          out = fs.createWriteStream(argv.out,'binary')
        else
          out = process.stdout
        LOG.debug "submitting:",options
        req = request.get options
        req.on 'response', (response)=>
          unless /^2[0-9][0-9]$/.test response?.statusCode
            LOG.error "Expected 2XX-series status code. Found #{response?.statusCode}."
            if not argv['api-key'] and /^401$/.test response?.statusCode
              LOG.error "The 401 (Unauthorized) response is probably because you did not supply an API Key."
              LOG.error "Use '-a <KEY>' to specify a key on the command line,"
              LOG.error "or run '#{EXE} --xhelp' for more information.\n"
            process.exit 1
        req.pipe(out,{encoding:"binary"})
    return cmd
}
