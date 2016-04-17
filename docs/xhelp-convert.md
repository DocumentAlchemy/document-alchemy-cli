# "Extended Help" for the `convert` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy convert --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy convert --xhelp` for the real thing.)


```
Command-line interface to the DocumentAlchemy API.

convert <FILE> - convert a file into a different format or rendition

Usage: document-alchemy [OPTIONS] capture <URL> [OPTIONS]

Command-Specific Parameters
  -f, --to, --format  type of rendition to create

Common Parameters
  -a, --api-key  DocumentAlchemy API key
  -o, --out      file to write to; when absent or '-', stdout is used
  -s, --store    when true, save the generated document on the server
  -t, --ttl      time-to-live for the stored image
  -p, --param    extra name value pair to be passed with the REST call

Help & Other Meta-Parameters
  -?, --help     show help; may also be used following a command
                 name to get command-specific help
  -x, --xhelp    show detailed help; may also be used following a
                 command name to get extended help on the command
  --version      show version information
  -v, --verbose  be more chatty; can be repeated for more detail
  --quiet        be less chatty

Examples:
  document-alchemy convert foo.docx --to md
    convert an MS Word document to Markdown, piping result to STDOUT
  document-alchemy convert README.md --to pdf --out README.pdf
    convert a Markdown file to PDF, writing the result to README.pdf

ABOUT THIS COMMAND

  The 'convert' command invokes the primary DocumentAlchemy conversion
  endpoint to perform a wide variety of transformations depending upon the
  given input and request output formats.

  See <https://documentalchemy.com/api-doc> for a list of specific
  transformations and more information about this and other
  document-processing API methods.

  Supported input formats include: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, PPSX,
  HTML, PNG, JPEG, WebP, Markdown, JSON, CSV and others.

  Supported output formats include: PDF, DOCX, XLSX, PPTX, HTML, PNG, JPEG,
  WebP, Markdown, JSON, CSV, ZIP and plain-text.

  In addition several "special" output formats are supported, including
  'media.zip' (to extract all images from a PDF or Office document),
  'pages.zip' (to split a document into individual pages), 'combined.pdf' (to
  package multiple documents into a single PDF), and 'thumbnail.png' (to
  create a thumbnail image for the input document).

  The full set of conversions and supported parameters is too large (and
  frequently growing) to cover in this document. Instead, you may use the '-p'
  parameter to pass arbitrary name-value pairs to the underlying REST method.
  See <https://documentalchemy.com/api-doc> for detailed description of each
  conversion and the parameters it accepts.

  By default, this command will pipe the generated image to stdout.  The 'out'
  parameter can be used to specify a file instead.

  When the 'store' parameter is set to true, the generated image will be
  placed in the DocumentAlchemy document store and a JSON document containing
  a document identifier will be output instead.

  An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long
  the document should be stored. When omitted, a duration of 3600 seconds
  (one hour) is used by default.

  See <https://documentalchemy.com/api-doc> for more information about this
  endpoint and other document-processing API methods.

EXAMPLES

  The command:

  > document-alchemy convert foo.md --to pdf \
      -p numberpages true \
      -p papersize a4 \
      -o foo.pdf \
      -a dO6M2p9sKRMGQYub

  where:
  - 'foo.md' is the file to convert
  - 'foo.pdf' is the file to save the generated document to, and
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key

  will generate a PDF representation of a Markdown document. The PDF will be
  "printed" on A4 paper and pages will be numbered.

  The command:

  > document-alchemy convert bar.doc --to docx -o bar.docx \
      --store \
      -a dO6M2p9sKRMGQYub

  will convert an "old-style" Word document (DOC) into a "new-style" Word
  document (DOCX), and store the image within the DocumentAlchemy filestore
  for one hour (the default "time-to-live" value).

  The command:

  > document-alchemy convert bar.doc --to md \
      -a dO6M2p9sKRMGQYub

  will convert a Word document into a Markdown document, writing the result to
  stdout.

```
