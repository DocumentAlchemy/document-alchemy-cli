# "Extended Help" for the `qrcode` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy qrcode --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy qrcode --xhelp` for the real thing.)

For more information about the DocumentAlchemy CLI project, see <https://github.com/documentalchemy/document-alchemy-cli>.

For more information about DocumentAlchemy, see <https://documentalchemy.com/>.  There you can also find detailed API documentation for [the QR Code generation endpoint](https://documentalchemy.com/api-doc#!/Type-specific_Specializations/get_data_rendition_qr_png) and an [online QR code generator](https://documentalchemy.com/demo/qr-code) that is backed by the same endpoint.

```
Command-line interface to the DocumentAlchemy API.

qrcode <DATA> - generate a QR code

Usage: document-alchemy [OPTIONS] qrcode <DATA> [OPTIONS]

Command-Specific Parameters
  -z, -w, --size, --width  size (height and width) of the generated image,
                           in pixels
  -e, --ecl                error-correction level, from 'l' is the lowest
                           level, 'h' is the highest level
                           [choices: "l", "m", "q", "h"]
  -r, --border             when true, include a small background-colored
                           border around the image
  -f, --fg, --foreground   foreground color as a hex string (e.g. '#FF0000')
                           or an RGB triplet (e.g., 'rgb(255,0,0)')
  -b, --bg, --background   background color as a hex string (e.g. '#00FFFF')
                           or an RGB triplet (e.g., 'rgb(0,255,255)')

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

ABOUT THIS COMMAND

  The 'qrcode' command generates a PNG image encoding the specified data as QR
  code by invoking the '/data/-/rendition/qr.png' endpoint.

  Specifically, this endpoint generates "Model 2" QR codes, capable of storing
  up to 7089 digits, 4296 alphanumeric characters or 2953 bytes (encoded in
  the ISO-8995-1 character set).

  All parameters other than DATA are optional.

  The 'size' parameter specifies the height and width of the (always square)
  image, in pixels. When missing, a 400-by-400 pixel image is generated.

  The 'ecl' parameter specifies the “error correction level” to use when
  generating the QR code. From highest to lowest level of error correction,
  value values are H, Q, M and L. When missing, the highest level of error
  correction (H) is used. Note that the volume of data that can be encoded in
  a QR code decreases as the level of error-correction increases.

  Unless the 'border' parameter is set to false, a thin (module-sized) border
  will be placed around the image.

  The 'fg' and 'bg' parameters specify the foreground and background colors to
  use when generating the QR code image, respectively. Values may take the
  form of #RRGGBB hex strings (e.g., #FF0000) or rgb triplets (e.g.,
  rgb(255,0,0)). When missing, the foreground color defaults to black
  (#000000) and the background color defaults to white (#FFFFFF). Note that QR
  code readers may have difficulty reading QR codes with inverse or
  low-contrast color schemes.

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

  The 'qrcode' command recognizes the following extended parameters.

    -z --size    - Size of the generated image (in pixels). Since QR codes
                   are square this value specifies both the width and
                   height of the generated image.
                   Example: -z 600

    -e --ecl     - The “error correction level” to use when generating
                   the QR code. Acceptable values are: 'l', 'm', 'q'
                   and 'h'.

                   At higher levels of error-correction, the "modules"
                   (boxes) that comprise the QR code are smaller and
                   more numerous. This allows the data to be encoded
                   with greater redundancy, but also supports less
                   encoded data overall

                   At ecl level 'l' it estimated that the code can still
                   be read when 7%  of the image is unreadable.

                   At ecl level 'm' it estimated that the code can still
                   be read when 15% of the image is unreadable.

                   At ecl level 'q' it estimated that the code can still
                   be read when 25% of the image is unreadable.

                   At ecl level 'h' it estimated that the code can still
                   be read when 30% of the image is unreadable.

                   Example: --ecl q

    -r --border  - When set, a small border will be added around the
                   QR. This does not change the size of the image as
                   specified by '-z' (and hence slightly reduces the size
                   of the QR-code part of the image.)
                   Example: --border
                   Example: --no-border

    -fg --foreground
    -bg --background
                 - Foreground (module) and background colors to use when
                   painting the QR code, as HTML-style hex digits or 'rbg'
                   strings. Of course, if the contrast between the
                   foreground and background colors used in the image is
                   not high enough, QR code readers may have trouble reading
                   the code.

                   Example: --fg #FF0000
                   Example: --fg rgb(255,0,0) --bg rgb(0,255,255)

EXAMPLES

  The command:

  > document-alchemy qrcode "Hello World!" -o hello.png -a dO6M2p9sKRMGQYub

  where:
  - 'Hello World!' is the text to encode,
  - 'hello.png' is the file to save the generated image to, and
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

  generates a file named 'hello.png' containing a PNG image encoding the text
  'Hello World!'.

  The command:

  > document-alchemy qrcode "http://example.com/" -s 600 -e m \
      --no-border -a dO6M2p9sKRMGQYub

  where:
  - 'http://example.com/' is the text to encode,
  - '600' is size (width and height) of the generated image, in pixels
  - 'm' is the error-correction level (medium)
  - 'dO6M2p9sKRMGQYub' is your DocumentAlchemy API Key.

  writes a 600x600 PNG image encoding the URL 'http://example.com' to stdout.

```
