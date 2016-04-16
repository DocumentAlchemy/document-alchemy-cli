yargs                   = require 'yargs'
path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
Util                    = require('inote-util').Util
request                 = require 'request'
BaseCommand             = require(path.join(LIB_DIR,"commands","_base-command")).BaseCommand
Shared                  = require(path.join(LIB_DIR,"shared"))

class Capture extends BaseCommand

  _command:()=>"capture <URL>"

  _describe:()=>"capture a screenshot"

  _extended_help: ()=>
    console.log "ABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'capture' command generates a screenshot of a web page invoking the '/document/-/rendition/{FORMAT}' endpoint.

    By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "A SIMPLE EXAMPLE\n"
    console.log Shared.wrap """
    > #{@exe} capture https://google.com/ -o capture.png -a dO6M2p9sKRMGQYub

    where:
    - 'https://google.com/' is the URL to capture
    - 'capture.png' is the file to save the generated image to, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

    """

  config_params:{
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

  _make_builder:(config)=>
    (subargs)=>
      subargs.options {
        "f": { group:"Command-Specific Parameters", alias:"format",                choices:["png","jpg"], requiresArg:true,  default:(config.capture["format"] ? "png"), describe:"type of image file to create#{@nad}"                     }
        "w": { group:"Command-Specific Parameters", alias:["bw","browser-width"],  number:true,           requiresArg:true,  default:(config.capture["bw"] ? 1024),      describe:"width of the browser's \"viewport\", in pixels#{@nad}"   }
        "h": { group:"Command-Specific Parameters", alias:["bh","browser-height"], number:true,           requiresArg:true,  default:config.capture["bh"],               describe:"height of the browser's \"viewport\", in pixels#{@nad}"  }
        "W": { group:"Command-Specific Parameters", alias:["iw","image-width"],    number:true,           requiresArg:true,  default:config.capture["iw"],               describe:"width of the generated image, in pixels#{@nad}"          }
        "H": { group:"Command-Specific Parameters", alias:["ih","image-height"],   number:true,           requiresArg:true,  default:config.capture["ih"],               describe:"height of the generated image, in pixels#{@nad}"         }
        "E": { group:"Command-Specific Parameters", alias:["ei","enlarge"],        boolean:true,          requiresArg:false, default:(config.capture["ei"] ? false),     describe:"when false, the source image will not be enlarged if it already fits in the specified image width and height.#{@nad}" }
        "R": { group:"Command-Specific Parameters", alias:["header"],              type:"string",         requiresArg:true,  default:config.capture["header"],           describe:"HTTP header to include in the request in the form \"name: value\"; may be repeated.#{@nad}" }
      }
      subargs.usage("Usage: #{@exe} [OPTIONS] capture <URL> [OPTIONS]")
      subargs.example("#{@exe} capture https://example.com/","#{@nad}capture a screenshot of https://example.com at the default size and resolution, piping result to STDOUT")
      subargs.example("#{@exe} capture https://example.com/ -o eg.png","#{@nad}capture a screenshot of https://example.com at the default size and resolution and save result to eg.png")
      subargs.check (argv)=>
        @_arg_check(argv)
        if argv._[0] is 'capture'
          url = argv._[1]
          unless /^https?:\/\//.test url
            throw new Error("<URL> parameter must start with 'http://' or 'https://'. Found '#{url}'.")
        return true

  _handler:(argv)=>
    @log.info "Capturing #{argv.f} screenshot of #{argv.URL}..."
    options = {
      url: "#{@url_base}/document/-/rendition/#{argv.f}"
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
    @log.debug "submitting:",options
    req = request.get options
    req.on 'response', (response)=>
      unless /^2[0-9][0-9]$/.test response?.statusCode
        @log.error "Expected 2XX-series status code. Found #{response?.statusCode}."
        if not argv['api-key'] and /^401$/.test response?.statusCode
          @log.error "The 401 (Unauthorized) response is probably because you did not supply an API Key."
          @log.error "Use '-a <KEY>' to specify a key on the command line,"
          @log.error "or run '#{@exe} --xhelp' for more information.\n"
        process.exit 1
    req.pipe(out,{encoding:"binary"})

module.exports = new Capture()
