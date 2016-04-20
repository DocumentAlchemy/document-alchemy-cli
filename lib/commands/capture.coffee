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
    console.log "\nCOMMAND-SPECIFIC PARAMETERS\n"
    console.log Shared.wrap """
      The 'capture' command supports the following extended parameters:

        -f --format  - The format of the image to create, defaults to 'png'.

                       Example: -f jpg

        -o --out     - File to write response to.  When missing or '-', the
                       respsonse document is written to stdout instead.

                       Example: -o foo.pdf

        -w --bw --browser-width
        -h --bh --browser-height
                     - The width and height (in pixels) of the browser
                       "viewport" when the screenshot is captured.

                       When missing, '-w' defaults to 1024.

                       When '-h' is missing, the viewport will be tall
                       enough to capture the full content of the page.

                       Example: -w 1920
                       Example: -w 800 -h 600

        -W --iw --image-width
        -H --ih --image-height
                     - The width and height (in pixels) of the generated image.
                       When needed, the "raw" screenshot will be scaled
                       (preserving the original aspect ratio) until it fits
                       within the box specified by --iw and --ih.

                       When both --iw and --ih are missing, the raw screenshot
                       will not be resized.

                       When --iw is specified but --ih is not (or is set to '0'),
                       the image will be scaled (preserving aspect ratio) until
                       it is exactly --iw pixels wide.

                       When --ih is specified but --iw is not (or is set to '0'),
                       the image will be scaled (preserving aspect ratio) until
                       it is exactly --ih pixels tall.

                       When both --iw and --ih are specified, the image will be
                       scaled until ONE of the two dimensions is exactly as
                       specified (once again, while preserving the original
                       apsect ratio).

                       Example: --iw 800
                       Example: --iw 900 --ih 600

        -E --ei --enlarge
                     - By default, the original image is only scaled DOWN in
                       size. As long as original viewport (bw x bh) fits within
                       the requested image size (iw x ih) the image will be
                       left alone.

                       When --enlarge is set, raw images smaller than the
                       requested image size will be scaled UP until at least
                       one dimension matches the requested value (preserving
                       aspect ratio).

                       Example: --enlarge
                       Example: --no-enlarge

        -R --header  - An HTTP request header to submit with the request, in the
                       form "name: value".  May be repeated multiple times to set
                       multiple header values.

                       Example: -R 'cookie: foo=bar; foo2=bar2'
                                -R 'X-Special: TRUE'

    """
    console.log "EXAMPLES\n"
    console.log Shared.wrap """
    The command:

    > #{@exe} capture https://google.com/ -o capture.png \\
        -a dO6M2p9sKRMGQYub

    where:
    - 'https://google.com/' is the URL to capture
    - 'capture.png' is the file to save the generated image to, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key
    will generate a file named 'capture.png' containing a screenshot of 'https://google.com/' at the default resolution and size.


    The command:

    > #{@exe} capture https://google.com/ -o capture.png \\
        -bw 1200 -iw 400 -a dO6M2p9sKRMGQYub

    where:
    - 'https://google.com/' is the URL to capture
    - 'capture.png' is the file to save the generated image to,
    - '1200' is the width of the browser viewport,
    - '400' is the desired width of the output image, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key
    will generate a file named 'capture.png' containing a screenshot of 'https://google.com/' at 1200 pixels wide, and then scale that image to be 400 pixels wide.

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
          "format"  :/^format$/i
        }
      )
    ]
  }

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.capture ?= {}
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
    @_process_get_and_write_response(argv,options)

module.exports = new Capture()
