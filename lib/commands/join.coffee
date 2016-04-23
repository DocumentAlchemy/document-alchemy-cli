path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
BaseCommand             = require(path.join(LIB_DIR,"commands","_base-command")).BaseCommand
Util                    = require('inote-util').Util
Shared                  = require(path.join(LIB_DIR,"shared"))

class Join extends BaseCommand

  _command:()=>"join <FILES...>"

  _describe:()=>"combine two or more files into a single PDF"

  _extended_help: ()=>
    console.log "\nABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'join' command combines two or more MS Office and PDF files into a single PDF using the /documents/-/rendition/combined.pdf endpoint.

    There are no command-specific parameters for `join`. It simply accepts a list of files to be combined.  Files are combined in the order in which they are listed.

    By default, this command will pipe the generated document to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated document will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "EXAMPLES\n"
    console.log Shared.wrap """
      The command:

      > #{@exe} join Input-1.pdf Input-2.pdf \\
          -o Output.pdf -a dO6M2p9sKRMGQYub

      where:
      - 'Input-1.pdf' and 'Input-2.pdf' are the files you wish to combine
      - 'Output.pdf' is the file to save the generated document to, and
      - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

      generates a file named 'Output.pdf' containing the contents of Input-1.pdf followed by the contents of Input-2.pdf.

      The command:

      > #{@exe} join Input-1.docx Input-2.pdf Input-3.pptx

      writes to stdout a PDF document that combines the listed files (which include both MS Office and PDF documents).

    """

  config_params:null

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.join ?= {}
      subargs.usage("Usage: #{@exe} [OPTIONS] join <FILES...>")
      subargs.example("#{@exe} join F1.docx F2.pptx F3.pdf","#{@nad}combines F1.docx, F2.pptx and F3.pdf into a single PDF document, piping the result to STDOUT")
      subargs.check (argv)=>
        @_arg_check(argv)
        return true


  _handler:(argv)=>
    unless argv.FILES?.length > 1
      throw new Error("At least two files are required in 'join'.")
    else
      @log.info "Joining #{argv.FILES.join(', ')}."
      options = {
        url: "#{@url_base}/documents/-/rendition/combined.pdf"
        headers: { "User-Agent":Shared.ua() }
      }
      if argv['api-key']?
        options.headers.Authorization = "da.key=#{argv['api-key']}"
      files = []
      for file in argv.FILES
        unless fs.existsSync file
          throw new Error("File '#{file}' not found.")
        else
          files.push file
      @_process_post_file_and_write_response(argv,options,"document",files)

module.exports = new Join()
