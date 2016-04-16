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

class QrCode extends BaseCommand

  _command:()=>"qrcode <DATA>"

  _describe:()=>"generate a QR code"

  _extended_help: ()=>
    console.log "\nABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'qrcode' command generates a PNG image encoding the specified data as QR code by invoking the '/data/-/rendition/qr.png' endpoint.

    All parameters other than DATA are optional.

    The 'size' parameter specifies the height and width of the (always square) image, in pixels. When missing, a 400-by-400 pixel image is generated.

    The 'ecl' parameter specifies the “error correction level” to use when generating the QR code. From highest to lowest level of error correction, value values are H, Q, M and L. When missing, the highest level of error correction (H) is used. Note that the volume of data that can be encoded in a QR code decreases as the level of error-correction increases.

    Unless the 'border' parameter is set to false, a thin (module-sized) border will be placed around the image.

    The 'fg' and 'bg' parameters specify the foreground and background colors to use when generating the QR code image, respectively. Values may take the form of #RRGGBB hex strings (e.g., #FF0000) or rgb triplets (e.g., rgb(255,0,0)). When missing, the foreground color defaults to black (#000000) and the background color defaults to white (#FFFFFF). Note that QR code readers may have difficulty reading QR codes with inverse or low-contrast color schemes.

    By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "EXAMPLES\n"
    console.log Shared.wrap """
      The command:

      > #{@exe} qrcode "Hello World!" -o hello.png -a dO6M2p9sKRMGQYub

      where:
      - 'Hello World!' is the text to encode,
      - 'hello.png' is the file to save the generated image to, and
      - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

      generates a file named 'hello.png' containing a PNG image encoding the text 'Hello World!'.

      The command:

      > #{@exe} qrcode "http://example.com/" -s 600 -e m \\
          --no-border -a dO6M2p9sKRMGQYub

      where:
      - 'http://example.com/' is the text to encode,
      - '600' is size (width and height) of the generated image, in pixels
      - 'm' is the error-correction level (medium)
      - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

      writes a 600x600 PNG image encoding the URL 'http://example.com' to stdout.

    """


  config_params:{
    "qrcode": [
      /^qrcode$/i
      ((v)=>
        return Shared.parse_config v, {
          "z" :/^((s(ize)?)|(w(idth)?))$/i
          "e" :/^e((rror)?[-_\.]?c(orrection)?[-_\.]?l(evel))?$/i
          "r" :[/^((border)|(r))$/i, Util.truthy_string]
          "f" :/^f((ore)?[-_\.]?g(round)?)?$/i
          "b" :/^b((ack)?[-_\.]?g(round)?)?$/i
        }
      )
    ]
  }

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.qrcode ?= {}
      subargs.options {
        "z": { group:"Command-Specific Parameters", alias:["w","size","width"],  number:true, requiresArg:true, default:(config.qrcode.z ? 400), describe:"size (height and width) of the generated image, in pixels#{@nad}"   }
        "e": { group:"Command-Specific Parameters", alias:["ecl"], choices:["l","m","q","h"], requiresArg:true, default:(config.qrcode.e ? "h"), describe:"error-correction level, from 'l' is the lowest level, 'h' is the highest level" }
        "r": { group:"Command-Specific Parameters", alias:["border"], boolean:true, default:(config.qrcode.r ? true), describe:"when true, include a small background-colored border around the image#{@nad}" }
        "f": { group:"Command-Specific Parameters", alias:["fg","foreground"], type:"string", default:(config.qrcode.f ? "#000000"),defaultDescription:(if config.qrcode.f? then null else "black"), describe:"foreground color as a hex string (e.g. '#FF0000') or an RGB triplet (e.g., 'rgb(255,0,0)')#{@nad}" }
        "b": { group:"Command-Specific Parameters", alias:["bg","background"], type:"string", default:(config.qrcode.b ? "#FFFFFF"),defaultDescription:(if config.qrcode.f? then null else "white"), describe:"background color as a hex string (e.g. '#00FFFF') or an RGB triplet (e.g., 'rgb(0,255,255)')#{@nad}" }
      }
      subargs.check (argv)=>
        @_arg_check(argv)
        return true

  _handler:(argv)=>
    @log.info "Generating QR Code..."
    options = {
      url: "#{@url_base}/data/-/rendition/qr.png"
      qs: { data: argv.DATA }
      headers: { "User-Agent":Shared.ua() }
    }
    if argv['api-key']?
      options.headers.Authorization = "da.key=#{argv['api-key']}"
    for n in ['size','ecl','border','fg','bg','ttl','store']
      if argv[n]?
        options.qs[n] = argv[n]
    @_process_get_and_write_response(argv,options)

module.exports = new QrCode()
