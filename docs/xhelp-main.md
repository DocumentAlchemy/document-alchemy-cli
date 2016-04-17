# "Extended Help" for the DocumentAlchemy CLI Application

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy --xhelp` for the real thing.)

```
Command-line interface to the DocumentAlchemy API.
Usage: document-alchemy [OPTIONS] <COMMAND> [OPTIONS]

Commands:
  capture <URL>   capture a screenshot
  convert <FILE>  convert a file into a different format or rendition
  qrcode <DATA>   generate a QR code

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
  document-alchemy --xhelp        show extended help
  document-alchemy <CMD> --help   show help for the command <CMD>
  document-alchemy <CMD> --xhelp  show extended help for the command <CMD>


ABOUT THIS APPLICATION

  document-alchemy is a command-line interface to the DocumentAlchemy API.
  Using document-alchemy you can easily invoke a number of document processing
  methods directly from the command line.

  PLEASE NOTE: Before using this program you will need a DocumentAlchemy API
  key. If you don't have one, you can get one immediately and for free by
  signing up for DocumentAlchemy at <https://documentalchemy.com/>. Once
  you've signed up you'll find your API key by selecting "My API Keys" under
  your "account" menu in the menu bar.

  In the interim you can also use this temporary API Key: 'dO6M2p9sKRMGQYub'.

  As an example, one simple DocumentAlchemy API method will generate a QR
  code.  To invoke that REST method from the command line using
  document-alchemy, you may enter an command like the following:

  document-alchemy qrcode "Hello World!" -o qr-hello.png -a dO6M2p9sKRMGQYub

  This will generate a file named `qr-hello.png` that contains an image of a
  QR code encoding the text "Hello World!".


CONFIGURATION

  You may set "persistent" command-line parameters by creating a configuration
  file.

  The file must be named '.documentalchemycli.json'.

  document-alchemy will look for a configuration file in two places: 1) the
  current working directory and 2) the user's 'HOME' directory.

  If a file is found in both places they will be COMBINED to set the overall
  execution context.  Values set in the current working directory's
  configuration file will override those found in the home-directory's
  configuration file.

  Both configuration files define "default" values.  Any parameters passed on
  the command line will override those found in a configuration file.

  For example, to set a persistent value for the API Key (so you do not need
  to pass it on the command line every time), you can create a JSON document
  such as:

  { "api-key":"dO6M2p9sKRMGQYub" }

  and save it as '.documentalchemycli.json' in your home directory.

  To set commmand-specific parameters, place them in a map under the name of
  the command.  For instance, the 'qrcode' command supports a `size` parameter
  which controls the size of the generate image (in pixels).  To set this
  value in the configuration file, you may use:

  { "api-key":"dO6M2p9sKRMGQYub", "qrcode": { "size":280 } }

  Now you may invoke the QR code method via:

  document-alchemy qrcode "Hello World!" -o qr-hello.png

  which will generate a 280-by-280 pixel image.

  Note that '.documentalchemycli.json' is parsed as a true JSON file--comments
  and other JavaScript-style code is not allowed.


COMMON PARAMETERS

  There are a handful of command-line arguments that are shared by all
  commands. These are enumerated below.

    -a --api-key - DocumentAlchemy API key to be submitted with the request.
                   Example: -a dO6M2p9sKRMGQYub

    -o --out     - File to write response to.  When missing or '-', the
                   respsonse document is written to stdout instead.
                   Example: -o foo.pdf

    -s --store   - When used, rather than returning the generated document,
                   the document will be stored in the server's (temporary)
                   file store.  In this case a JSON document containing a
                   identifier ('id') and a URL for the stored file ('href')
                   will be returned instead.
                   Example: --store
                   Example: --no-store

    -t --ttl     - When 'store' is set, this parameter specifies the duration
                   (in seconds) that the document should be stored for.
                   The default is 3600 (one hour). The maximum value is
                   86400 (one day).
                   Example: -t 14400

    -p --param   - This argument specifies an "extra" query string or request
                   body parameter to send to the underlying REST method with
                   the rest of the request. This is useful when you'd like to
                   set a parameter that is not otherwise exposed in the CLI.
                   This argument must be followed by TWO values.  '--param'
                   may be repeated more than once to set more than one value.
                   Example: -p name1 value1 -p "name two" "value two"


ABOUT DOCUMENT ALCHEMY

  Document Alchemy provides a RESTful web-service API for generating,
  transforming, converting and processing documents in various formats,
  including:

   - MS Office documents such as Microsoft Word, Excel and PowerPoint.
   - Open source office documents such Apache OpenOffice files.
   - Adobe's Portable Document Format (PDF).
   - HTML, Markdown and other text formats.
  - Images such as PNG, JPEG, GIF and others.

  More information, free, online document conversion tools and interactive
  documentation of our document processing API can be found at
  <https://documentalchemy.com>.

  You can follow us on Twitter at <@DocumentAlchemy>.

  If you have any questions, comments or feedback for us, you can reach us via
  our online contact form at <https://documentalchemy.com/contact-us> or via
  the email addresses listed on that page.


THIS APPLICATION IS OPEN SOURCE SOFTWARE

  The source code and documentation for document-alchemy is available for you
  to learn from, modify or extend.

  It is made available under an MIT-style license.

  You'll find it at <https://github.com/documentalchemy/document-alchemy-cli>.

  We welcome your questions, comments, feedback or pull requests.

```
