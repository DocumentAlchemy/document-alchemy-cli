# "Extended Help" for the `transform` command

For your convenience, the following is a capture of the output you'll see when you run `document-alchemy transform --xhelp`.

(Note that this might not reflect the absolute latest version of the in-app documentation.  Use `document-alchemy transform --xhelp` for the real thing.)

For more information about the DocumentAlchemy CLI project, see <https://github.com/documentalchemy/document-alchemy-cli>.

For more information about DocumentAlchemy, see <https://documentalchemy.com/>.  There you can also find detailed API documentation for [the QR Code generation endpoint](https://documentalchemy.com/api-doc#!/Type-specific_Specializations/get_data_rendition_qr_png) and an [online QR code generator](https://documentalchemy.com/demo/qr-code) that is backed by the same endpoint.

```
Command-line interface to the DocumentAlchemy API.

transform - transform an image

Usage: document-alchemy [OPTIONS] transform <IMAGE> <ACTION>

Command-Specific Parameters
  -f, --format  type of image file to create

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

  The 'transform' command transforms an image by invoking the
  '/document/-/rendition/{format}/transform/{action}' endpoint.

  The general form of the transform command is:

      transform <IMAGE> <ACTION>

  where <IMAGE> is the location of the image to be transformed and <ACTION> is
  an "action string", as described below.

  Each "action string" contains a sub-command followed by sub-command-specific
  parameters.

  resize <WIDTH> <HEIGHT>
  - shrink an image until it fits inside the specified box

  resize <WIDTH> <HEIGHT> enlarge
  - shrink or grow an image until in barely fits inside the specified box

  resize <WIDTH> <HEIGHT> [<GRAVITY>]
  - shrink an image until one of its dimensions matches the specified <WIDTH>
  or <HEIGHT>, then crop the image to the exact <WIDTH> and <HEIGHT>
  - the optional "gravity" parameter must be one of 'n', 's', 'e', 'w', 'c'
  and specfies which edge (or center) the cropping should be centered on.

  crop <TOP> <LEFT> <WIDTH> <HEIGHT>
  - extract the specified portion of the image

  rotate [<ANGLE>]
  - rotate an image; the optional <ANGLE> parameter must be one of '90',
  '180', '270' or 'auto'.  The first three specify the angle of rotation in
  degrees (in the clockwise direction). When <ANGLE> is omitted or 'auto', the
  image's EXIF metadata (if any) to orient the image.

  flip <AXIS>
  - flip an image over an axis; the <AXIS> parameter must be 'h' or 'x' (to
  flip over the horizontal axis) or 'v' or 'y' (to flip over the vertical
  axis).

  blur [<RADIUS>]
  - blur the image, using the optional <RADIUS> value when provided

  sharpen [<RADIUS>]
  - sharpen the image, using the optional <RADIUS> value when provided

  gs
  - convert the image to grayscale; the sub-commands 'grayscale' and
  'greyscale' are aliases for this sub-command.

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
```
