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

  _extended_help: ()=>
    console.log "ABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'convert' command invokes the primary DocumentAlchemy conversion endpoint to perform a wide variety of transformations depending upon the given input and request output formats.

    See <https://documentalchemy.com/api-doc> for a list of specific transformations and more information about this and other document-processing API methods.

    Supported input formats include: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, PPSX, HTML, PNG, JPEG, WebP, Markdown, JSON, CSV and others.

    Supported output formats include: PDF, DOCX, XLSX, PPTX, HTML, PNG, JPEG, WebP, Markdown, JSON, CSV, ZIP and plain-text.

    In addition several "special" output formats are supported, including 'media.zip' (to extract all images from a PDF or Office document), 'pages.zip' (to split a document into individual pages), 'combined.pdf' (to package multiple documents into a single PDF), and 'thumbnail.png' (to create a thumbnail image for the input document).

    The full set of conversions and supported parameters is too large (and frequently growing) to cover in this document. Instead, you may use the '-p' parameter to pass arbitrary name-value pairs to the underlying REST method. See <https://documentalchemy.com/api-doc> for detailed description of each conversion and the parameters it accepts.

    By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """
    console.log "EXAMPLES\n"
    console.log Shared.wrap """
    The command:

    > #{@exe} convert foo.md --to pdf \\
        -p numberpages true \\
        -p papersize a4 \\
        -o foo.pdf \\
        -a dO6M2p9sKRMGQYub

    where:
    - 'foo.md' is the file to convert
    - 'foo.pdf' is the file to save the generated document to, and
    - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key
    will generate a PDF representation of a Markdown document. The PDF will be "printed" on A4 paper and pages will be numbered.

    The command:

    > #{@exe} convert bar.doc --to docx -o bar.docx \\
        --store \\
        -a dO6M2p9sKRMGQYub

    will convert an "old-style" Word document (DOC) into a "new-style" Word document (DOCX), and store the image within the DocumentAlchemy filestore for one hour (the default "time-to-live" value).

    The command:

    > #{@exe} convert bar.doc --to md \\
        -a dO6M2p9sKRMGQYub

    will convert a Word document into a Markdown document, writing the result to stdout.

    """

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
    @log.info "Converting file at #{argv.FILE} to #{argv.f}."
    options = {
      url: "#{@url_base}/document/-/rendition/#{argv.f}"
      headers: { "User-Agent":Shared.ua() }
    }
    if argv['api-key']?
      options.headers.Authorization = "da.key=#{argv['api-key']}"
    @_process_post_file_and_write_response(argv,options,"document",argv.FILE)

module.exports = new Convert()
