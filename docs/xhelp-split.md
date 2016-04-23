# "Extended Help" for the `split` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy split --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy split --xhelp` for the real thing.)

For more information about the DocumentAlchemy CLI project, see <https://github.com/documentalchemy/document-alchemy-cli>.

For more information about DocumentAlchemy, see <https://documentalchemy.com/>. There you can also find detailed API documentation for [the split-PDF  endpoint](https://documentalchemy.com/api-doc#!/Type-specific_Specializations/post_document_rendition_pages_zip) and a live demonstration of the &ldquo;slpit&rdquo; functionality in the &ldquo;[Split a PDF into Pages](https://documentalchemy.com/demo/split-pdf)&rdquo; online tool.


```
Command-line interface to the DocumentAlchemy API.
split <FILE> - break a PDF document into collection of individual pages
Usage: document-alchemy [OPTIONS] split <FILE>

Common Parameters
  -a, --api-key  DocumentAlchemy API key
  -o, --out      file to write to; when absent or '-', stdout is used
  -s, --store    when true, save the generated document on the server
  -t, --ttl      time-to-live for the stored image, ignored when --store is false
  -p, --param    extra name value pair to be passed with the REST call

Help & Other Meta-Parameters
  -?, --help     show help; may also be used following a command name to get
                 command-specific help
  -x, --xhelp    show detailed help; may also be used following a command name to get
                 extended help on the given command
  --version      show version information
  -v, --verbose  be more chatty; can be repeated up to 4 times for more detail.


Examples:
  document-alchemy split IN.pdf -o OUT.zip  generates OUT.zip, containing each page of
                                            IN.pdf as stand-alone PDF files.


ABOUT THIS COMMAND

  The 'split' command takes a PDF document and returns a ZIP-archive
  containing a set of PDF documents, one for each page of the original
  document.  It is backed by the /document/-/rendition/pages.zip endpoint.

  There are no command-specific parameters for `split`. It simply accepts a
  single PDF file to be split up.

  By default, this command will pipe the generated document to stdout.  The
  'out' parameter can be used to specify a file instead.

  When the 'store' parameter is set to true, the generated document will be
  placed in the DocumentAlchemy document store and a JSON document containing
  a document identifier will be output instead.

  An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long
  the document should be stored. When omitted, a duration of 3600 seconds
  (one hour) is used by default.

  See <https://documentalchemy.com/api-doc> for more information about this
  endpoint and other document-processing API methods.

EXAMPLES

  The command:

  > document-alchemy split Input.pdf -o Output.zip \
       -a dO6M2p9sKRMGQYub

  where:
  - 'Input.pdf' is the file you want to break up
  - 'Output.zip' is the generated archive of individual pages
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

  generates a file named 'Output.zip' containing the pages of Input.pdf as
  stand-alone PDF files.
```
