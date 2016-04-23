path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
BaseCommand             = require(path.join(LIB_DIR,"commands","_base-command")).BaseCommand
Util                    = require('inote-util').Util
Shared                  = require(path.join(LIB_DIR,"shared"))

class Split extends BaseCommand

  _command:()=>"split <FILE>"

  _describe:()=>"break a PDF document into collection of individual pages"

  _extended_help: ()=>
    console.log "\nABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'split' command takes a PDF document and returns a ZIP-archive containing a set of PDF documents, one for each page of the original document.  It is backed by the /document/-/rendition/pages.zip endpoint.

    There are no command-specific parameters for `split`. It simply accepts a single PDF file to be split up.

    By default, this command will pipe the generated document to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated document will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "EXAMPLES\n"
    console.log Shared.wrap """
      The command:

      > #{@exe} split Input.pdf -o Output.zip \\
           -a dO6M2p9sKRMGQYub

      where:
      - 'Input.pdf' is the file you want to break up
      - 'Output.zip' is the generated archive of individual pages
      - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

      generates a file named 'Output.zip' containing each page of Input.pdf as stand-alone PDF files.

    """

  config_params:null

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.split ?= {}
      subargs.usage("Usage: #{@exe} [OPTIONS] split <FILE>")
      subargs.example("#{@exe} split IN.pdf -o OUT.zip","#{@nad}generates OUT.zip, containing each page of IN.pdf as stand-alone PDF files.")
      subargs.nargs 1
      subargs.check (argv)=>
        @_arg_check(argv)
        return true


  _handler:(argv)=>
    unless argv.FILE?
      throw new Error("An single input file is required")
    else
      @log.info "Splitting #{argv.FILE}."
      options = {
        url: "#{@url_base}/document/-/rendition/pages.zip"
        headers: { "User-Agent":Shared.ua() }
      }
      if argv['api-key']?
        options.headers.Authorization = "da.key=#{argv['api-key']}"
      files = []
      @_process_post_file_and_write_response(argv,options,"document",argv.FILE)

module.exports = new Split()
