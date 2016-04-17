# "Extended Help" for the `capture` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy capture --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy capture --xhelp` for the real thing.)

For more information about the DocumentAlchemy CLI project, see <https://github.com/documentalchemy/document-alchemy-cli>.

For more information about DocumentAlchemy, see <https://documentalchemy.com/>. There you can also find detailed API documentation for [the web screen capture endpoint](https://documentalchemy.com/api-doc#!/Type-specific_Specializations/get_url_document_rendition_image) as well as a [web screenshot tool](https://documentalchemy.com/demo/url2png) and [responsive site tester](https://documentalchemy.com/demo/responsive-site-tester) that are backed by that same endpoint.

```
Command-line interface to the DocumentAlchemy API.

capture <URL> - capture a screenshot

Usage: document-alchemy [OPTIONS] capture <URL> [OPTIONS]

Command-Specific Parameters
  -f, --format                type of image file to create
                              [choices: "png", "jpg"]
  -w, --bw, --browser-width   width of the browser's "viewport"
  -h, --bh, --browser-height  height of the browser's "viewport"
  -W, --iw, --image-width     width of the generated image
  -H, --ih, --image-height    height of the generated image
  -E, --ei, --enlarge         when false, the source image will not
                              be enlarged if it already fits in the
                              specified image width and height.
  -R, --header                HTTP header to include in the request
                              in the form "name: value";
                              may be repeated.

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
  document-alchemy capture https://example.com/
     capture a screenshot of https://example.com at the default size
     and resolution, piping result to STDOUT
  document-alchemy capture https://example.com/ -o eg.png
     capture a screenshot of https://example.com at the default size
     and resolution and save result to eg.png

ABOUT THIS COMMAND

  The 'capture' command generates a screenshot of a web page invoking the
  '/document/-/rendition/{FORMAT}' endpoint.

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


COMMAND-SPECIFIC PARAMETERS

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

EXAMPLES

  The command:

  > document-alchemy capture https://google.com/ -o capture.png \
      -a dO6M2p9sKRMGQYub

  where:
  - 'https://google.com/' is the URL to capture
  - 'capture.png' is the file to save the generated image to, and
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key

  will generate a file named 'capture.png' containing a screenshot of
  'https://google.com/' at the default resolution and size.


  The command:

  > document-alchemy capture https://google.com/ -o capture.png \
      -bw 1200 -iw 400 -a dO6M2p9sKRMGQYub

  where:
  - 'https://google.com/' is the URL to capture
  - 'capture.png' is the file to save the generated image to,
  - '1200' is the width of the browser viewport,
  - '400' is the desired width of the output image, and
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key

  will generate a file named 'capture.png' containing a screenshot of
  'https://google.com/' at 1200 pixels wide, and then scale that image to be
  400 pixels wide.

```
