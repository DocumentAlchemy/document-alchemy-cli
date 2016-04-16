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
    console.log "A SIMPLE EXAMPLE\n"
    console.log Shared.wrap """
    > #{EXE} qrcode "Hello World!" -o hello.png -a dO6M2p9sKRMGQYub

    where:
    - 'Hello World!' is the text to encode,
    - 'hello.png' is the file to save the generated image to, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

    """

  config_params: {
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

  make_command: (config)->
    config.qrcode ?= {}
    cmd = {}
    cmd.command  =  "qrcode <DATA>"
    cmd.describe = "generate a QR code"
    cmd.builder  = (subargs)=>
      subargs.options {
        "z": { group:"Command-Specific Parameters", alias:["w","size","width"],  number:true, requiresArg:true, default:(config.qrcode.z ? 400), describe:"size (height and width) of the generated image, in pixels#{NAD}"   }
        "e": { group:"Command-Specific Parameters", alias:["ecl"], choices:["l","m","q","h"], requiresArg:true, default:(config.qrcode.e ? "h"), describe:"size (height and width) of the generated image, in pixels#{NAD}" }
        "r": { group:"Command-Specific Parameters", alias:["border"], boolean:true, default:(config.qrcode.r ? true), describe:"when true, include a small background-colored border around the image#{NAD}" }
        "f": { group:"Command-Specific Parameters", alias:["fg","foreground"], type:"string", default:(config.qrcode.f ? "#000000"),defaultDescription:(if config.qrcode.f? then null else "black"), describe:"foreground color as a hex string (e.g. '#FF0000') or an RGB triplet (e.g., 'rgb(255,0,0)')#{NAD}" }
        "b": { group:"Command-Specific Parameters", alias:["bg","background"], type:"string", default:(config.qrcode.b ? "#FFFFFF"),defaultDescription:(if config.qrcode.f? then null else "white"), describe:"background color as a hex string (e.g. '#00FFFF') or an RGB triplet (e.g., 'rgb(0,255,255)')#{NAD}" }
      }
      subargs.check (argv)=>
        Shared.handle_extended_help argv
        Shared.handle_help_and_version argv
        return true

    cmd.handler = (argv)=>
      Shared.command_run = true
      process.nextTick ()=>
        LOG.info "Generating QR Code..."
        options = {
          url: "#{URL_BASE}/data/-/rendition/qr.png"
          qs: { data: argv.DATA }
          headers: { "User-Agent":Shared.ua() }
        }
        if argv['api-key']?
          options.headers.Authorization = "da.key=#{argv['api-key']}"
        for n in ['size','ecl','border','fg','bg','ttl','store']
          if argv[n]?
            options.qs[n] = argv[n]
        LOG.debug "submitting:",options
        if argv.out?
          out = fs.createWriteStream(argv.out,'binary')
        else
          out = process.stdout
        req = request.get options
        req.on 'response', (response)=>
          unless /^2[0-9][0-9]$/.test response?.statusCode
            LOG.error "Expected 2XX-series status code. Found #{response?.statusCode}."
            if not argv['api-key'] and /^401$/.test response?.statusCode
              LOG.error "The 401 (Unauthorized) response is probably because"
              LOG.error "you did not supply an API Key."
              LOG.error "Use '-a <KEY>' to specify a key on the command line,"
              LOG.error "or run '#{EXE} --xhelp' for more information.\n"
            process.exit 1
        req.pipe(out,{encoding:"binary"})
    return cmd
}
