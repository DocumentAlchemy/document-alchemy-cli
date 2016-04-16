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

class Convert extends BaseCommand

  _command:()=>"convert <FILE>"

  _describe:()=>"convert a file into a different format or rendition"

  # _extended_help: ()=>
  #   console.log "ABOUT THIS COMMAND\n"
  #   console.log Shared.wrap """
  #   The 'capture' command generates a screenshot of a web page invoking the '/document/-/rendition/{FORMAT}' endpoint.
  #
  #   By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.
  #
  #   When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.
  #
  #   An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.
  #
  #   See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.
  #
  #   """
  #   console.log "EXAMPLES\n"
  #   console.log Shared.wrap """
  #   The command:
  #
  #   > #{@exe} capture https://google.com/ -o capture.png \\
  #       -a dO6M2p9sKRMGQYub
  #
  #   where:
  #   - 'https://google.com/' is the URL to capture
  #   - 'capture.png' is the file to save the generated image to, and
  #   - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key
  #   will generate a file named 'capture.png' containing a screenshot of 'https://google.com/' at the default resolution and size.
  #
  #   > #{@exe} capture https://google.com/ -o capture.png \\
  #       -bw 1200 -iw 400 -a dO6M2p9sKRMGQYub
  #
  #   The command:
  #
  #   where:
  #   - 'https://google.com/' is the URL to capture
  #   - 'capture.png' is the file to save the generated image to,
  #   - '1200' is the width of the browser viewport,
  #   - '400' is the desired width of the output image, and
  #   - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key
  #   will generate a file named 'capture.png' containing a screenshot of 'https://google.com/' at 1200 pixels wide, and then scale that image to be 400 pixels wide.
  #
  #   """

  config_params:{
    "convert": [
      /^convert$/i
      ((v)=>
        return Shared.parse_config v, {
          "f" :/^(to)|(f(ormat)?)$/i
        }
      )
    ]
  }

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.convert ?= {}
      subargs.options {
        "f": { group:"Command-Specific Parameters", alias:["to","format"], type:"string", requiresArg:true, default:(config.convert["f"] ? "pdf"), describe:"type of rendition to create#{@nad}" }
      }
      subargs.usage("Usage: #{@exe} [OPTIONS] convert <FILE> [OPTIONS]")
      subargs.example("#{@exe} convert foo.docx --to md","#{@nad}convert an MS Word document to Markdown, piping result to STDOUT")
      subargs.example("#{@exe} convert README.md --to pdf --out README.pdf","#{@nad}convert a Markdown file to PDF, writing the result to README.pdf")
      subargs.check (argv)=>
        @_arg_check(argv)
        return true

  _handler:(argv)=>
    @log.info "Converting file at #{argv.FILE} to #{argv.t}."
    options = {
      url: "#{@url_base}/document/-/rendition/#{argv.t}"
      headers: { "User-Agent":Shared.ua() }
    }
    if argv['api-key']?
      options.headers.Authorization = "da.key=#{argv['api-key']}"
    @_process_post_file_and_write_response(argv,options,"document",argv.FILE)

module.exports = new Convert()
