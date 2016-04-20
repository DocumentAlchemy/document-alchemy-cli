path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
BaseCommand             = require(path.join(LIB_DIR,"commands","_base-command")).BaseCommand
Util                    = require('inote-util').Util
Shared                  = require(path.join(LIB_DIR,"shared"))

class Transform extends BaseCommand

  _command:()=>"transform"

  _describe:()=>"transform an image"

  _extended_help: ()=>
    console.log "\nABOUT THIS COMMAND\n"
    console.log Shared.wrap """
    The 'transform' command transforms an image by invoking the '/document/-/rendition/{format}/transform/{action}' endpoint.

    The general form of the transform command is:

        transform <IMAGE> <ACTION>

    where <IMAGE> is the location of the image to be transformed and <ACTION> is an "action string", as described below.

    Each "action string" contains a sub-command followed by sub-command-specific parameters.

    resize <WIDTH> <HEIGHT>
    - shrink an image until it fits inside the specified box

    resize <WIDTH> <HEIGHT> enlarge
    - shrink or grow an image until in barely fits inside the specified box

    resize <WIDTH> <HEIGHT> [<GRAVITY>]
    - shrink an image until one of its dimensions matches the specified <WIDTH> or <HEIGHT>, then crop the image to the exact <WIDTH> and <HEIGHT>
    - the optional "gravity" parameter must be one of 'n', 's', 'e', 'w', 'c' and specfies which edge (or center) the cropping should be centered on.

    crop <TOP> <LEFT> <WIDTH> <HEIGHT>
    - extract the specified portion of the image

    rotate [<ANGLE>]
    - rotate an image; the optional <ANGLE> parameter must be one of '90', '180', '270' or 'auto'.  The first three specify the angle of rotation in degrees (in the clockwise direction). When <ANGLE> is omitted or 'auto', the image's EXIF metadata (if any) to orient the image.

    flip <AXIS>
    - flip an image over an axis; the <AXIS> parameter must be 'h' or 'x' (to flip over the horizontal axis) or 'v' or 'y' (to flip over the vertical axis).

    blur [<RADIUS>]
    - blur the image, using the optional <RADIUS> value when provided

    sharpen [<RADIUS>]
    - sharpen the image, using the optional <RADIUS> value when provided

    gs
    - convert the image to grayscale; the sub-commands 'grayscale' and 'greyscale' are aliases for this sub-command.

    By default, this command will pipe the generated image to stdout.  The 'out' parameter can be used to specify a file instead.

    When the 'store' parameter is set to true, the generated image will be placed in the DocumentAlchemy document store and a JSON document containing a document identifier will be output instead.

    An optional 'ttl' ("time-to-live") parameter specifies (in seconds) how long the document should be stored. When omitted, a duration of 3600 seconds (one hour) is used by default.

    See <https://documentalchemy.com/api-doc> for more information about this endpoint and other document-processing API methods.

    """

  config_params:{
    "transform": [
      /^transform$/i
      ((v)=>
        return Shared.parse_config v, {
          "f" :/^f(ormat)$/
        }
      )
    ]
  }

  _make_builder:(config)=>
    (subargs)=>
      config ?= {}
      config.transform ?= {}
      subargs.options {
        "f": { group:"Command-Specific Parameters", alias:"format",                choices:["png","jpg", "webp"], requiresArg:true,  default:(config.transform["f"] ? "png"), describe:"type of image file to create#{@nad}"                     }
      }
      subargs.usage("Usage: #{@exe} [OPTIONS] transform <IMAGE> <ACTION>")
      subargs.example("#{@exe} transform MY-IMAGE.PNG resize 240 160","#{@nad}resizes an image to at most 240x160 pixels, piping result to STDOUT")
      subargs.check (argv)=>
        @_arg_check(argv)
        return true

  _parse_resize:(args)=>
    unless args.length in [2,3]
      throw new Error("Expected 2 or 3 arguments following 'resize'. Found #{JSON.stringify(args)}")
    else
      width = Util.to_int(args.shift())
      height = Util.to_int(args.shift())
      unless width? and height?
        throw new Error("Expected two numeric values following 'resize', found '#{width}' and '#{height}'")
      else
        if args.length > 0
          enlarge = null
          gravity = null
          val = args.shift().toLowerCase()
          if /^enlarge?$/i.test val
            enlarge = true
          else if /^n(orth)?$/i.test val
            gravity = 'n'
          else if /^s(outh)?$/i.test val
            gravity = 's'
          else if /^e(ast)?$/i.test val
            gravity = 'e'
          else if /^w(est)?$/i.test val
            gravity = 'w'
          else if /^c(enter)?$/i.test val
            gravity = 'c'
          else
            throw new Error("Unexpected value '#{val}' after 'resize #{width} #{height}'.")
        else
          enlarge = argv.enlarge ? false
        if gravity?
          action = "S#{width},#{height},#{gravity}"
        else if enlarge
          action = "S#{width},#{height}"
        else
          action = "s#{width},#{height}"
    return action

  _parse_crop:(args)=>
    unless args.length is 4
      throw new Error("Expected 4 arguments following 'crop'. Found #{JSON.stringify(args)}")
    else
      top = Util.to_int(args.shift())
      left = Util.to_int(args.shift())
      width = Util.to_int(args.shift())
      height = Util.to_int(args.shift())
      unless top? and left? and width? and height?
        throw new Error("Expected four numeric values following 'crop', found '#{top}' '#{left}', '#{width}' and '#{height}'.")
      action = "X#{top},#{left},#{width},#{height}"
    return action

  _parse_rotate:(args)=>
    unless args.length in [0,1]
      throw new Error("Expected at most 1 argument following 'rotate'. Found #{JSON.stringify(args)}")
    else
      angle = "A"
      if args.length is 1
        angle = args.shift()
      if /^A(uto)?/i.test angle
        angle = "A"
      unless angle in [90,'90',180,'180',270,'270','A']
        throw new Error("Expected 90, 180, 270 or A following 'rotate'. Found #{angle}")
      else
        action = "R#{angle}"
    return action

  _parse_flip:(args)=>
    unless args.length is 1
      throw new Error("Expected exactly one argument following 'flip'. Found #{JSON.stringify(args)}")
    else
      axis = args.shift()
      if /^H|X$/i.test axis
        axis = "H"
      else if /^V|Y$/i.test axis
        axis = "V"
      else
        throw new Error("Expected X or Y following 'flip'. Found #{axis}.")
      action = "F#{axis}"
    return action

  _parse_blur:(args)=>
    unless args.length in [0,1]
      throw new Error("Expected at most 1 argument following 'blur'. Found #{JSON.stringify(args)}")
    else
      if args.length is 1
        radius = args.shift()
        unless Util.is_int(radius)
          throw new Error("Expected an integer radius following 'blur', found '#{radius}'.")
        else
          radius = Util.to_int(radius)
      else
        radius = ""
      action = "B#{radius}"
    return action

  _parse_sharpen:(args)=>
    unless args.length in [0,1]
      throw new Error("Expected at most 1 argument following 'sharpen'. Found #{JSON.stringify(args)}")
    else
      if args.length is 1
        radius = args.shift()
        unless Util.is_int(radius)
          throw new Error("Expected an integer radius following 'sharpen', found '#{radius}'.")
        else
          radius = Util.to_int(radius)
      else
        radius = ""
      action = "P#{radius}"
    return action

  _handler:(argv)=>
    args = [].concat(argv._)
    @log.info "Transforming image based on #{JSON.stringify(args)}."
    if args.shift() is "transform"
      format = argv.format ? "png"
      unless args.length > 1
        throw new Error("Expected at least 2 arguments following 'transform'. Found #{JSON.stringify(args)}.")
      else
        image = args.shift()
        unless fs.existsSync image
          throw new Error("Image file '#{image}' not found.")
        else
          action = null
          subcmd = args.shift()
          switch subcmd
            when "resize"
              action = @_parse_resize(args)
            when "crop"
              action = @_parse_crop(args)
            when "rotate"
              action = @_parse_rotate(args)
            when "flip"
              action = @_parse_flip(args)
            when "blur"
              action = @_parse_blur(args)
            when "focus"
              action = @_parse_focus(args)
            when "gs","grayscale","greyscale","GS","GRAYSCALE","GREYSCALE"
              action = "GS"
            else
              throw new Error("Unrecognized subcommand following 'transform'.  Found '#{subcmd}'.")
          options = {
            url: "#{@url_base}/document/-/rendition/#{format}/transform/#{action}"
            headers: { "User-Agent":Shared.ua() }
          }
          if argv['api-key']?
            options.headers.Authorization = "da.key=#{argv['api-key']}"
          @_process_post_file_and_write_response(argv,options,"document",image)
    else
      throw new Error("Unrecognized command in 'transform'. Expected 'transform'. Found #{argv._?[0]}.")

module.exports = new Transform()
