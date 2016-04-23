# "Extended Help" for the `join` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy join --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy join --xhelp` for the real thing.)

For more information about the DocumentAlchemy CLI project, see <https://github.com/documentalchemy/document-alchemy-cli>.

For more information about DocumentAlchemy, see <https://documentalchemy.com/>. There you can also find detailed API documentation for [the combine-documents  endpoint](https://documentalchemy.com/api-doc#!/Type-specific_Specializations/post_documents_rendition_combined_pdf) and live demonstrations of the &ldquo;join&rdquo; functionality in the &ldquo;[Combine PDFs Online](https://documentalchemy.com/demo/join-pdfs)&rdquo; and &ldquo;[Combine Microsoft Office Files Online](https://documentalchemy.com/demo/join-docs)&rdquo; tools.

```
Command-line interface to the DocumentAlchemy API.
join <FILES...> - combine two or more files into a single PDF
Usage: document-alchemy [OPTIONS] join <FILES...>

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
  --quiet        be less chatty

Examples:
  document-alchemy join F1.docx F2.pptx F3.pdf  combines F1.docx, F2.pptx and F3.pdf into
                                                a single PDF document, piping the result
                                                to STDOUT


ABOUT THIS COMMAND

  The 'join' command combines two or more MS Office and PDF files into a
  single PDF using the /documents/-/rendition/combined.pdf endpoint.

  There are no command-specific parameters for `join`. It simply accepts a
  list of files to be combined.  Files are combined in the order in which they
  are listed.

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

  > document-alchemy join Input-1.pdf Input-2.pdf \
      -o Output.pdf -a dO6M2p9sKRMGQYub

  where:
  - 'Input-1.pdf' and 'Input-2.pdf' are the files you wish to combine
  - 'Output.pdfg' is the file to save the generated document to, and
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

  generates a file named 'Output.pdf' containing the contents of Input-1.pdf
  followed by the contents of Input-2.pdf.

  The command:

  > document-alchemy join Input-1.docx Input-2.pdf Input-3.pptx

  writes to stdout a PDF document that combines the listed files (which
  include both MS Office and PDF documents).

```
