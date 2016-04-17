path                    = require 'path'
fs                      = require 'fs'
HOMEDIR                 = path.join(__dirname,'..','..')
IS_INSTRUMENTED         = fs.existsSync( path.join(HOMEDIR,'lib-cov') )
LIB_DIR                 = if IS_INSTRUMENTED then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
BaseCommand             = require(path.join(LIB_DIR,"commands","_base-command")).BaseCommand

class Debug extends BaseCommand

  _command:()=>"debug>"

  _describe:()=>false

  _extended_help: ()=>
    console.log "Hidden command to echo back input parameters, for use in debugging."

  config_params:null

  _make_builder:(config)=>
    (subargs)=>
      console.log "command debug: inside builder, config is: " + JSON.stringify(config)
      console.log "command debug: inside builder, subargs is: " + JSON.stringify(subargs)

  _handler:(argv)=>
    console.log "command debug: inside handler, argv is: " + JSON.stringify(argv)

module.exports = new Debug()
