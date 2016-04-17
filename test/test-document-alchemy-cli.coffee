should             = require 'should'
fs                 = require 'fs'
path               = require 'path'
HOMEDIR            = path.join(__dirname,'..')
LIB_DIR            = if fs.existsSync(path.join(HOMEDIR,'lib-cov')) then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')
DocumentAlchemyCLI = require(path.join(LIB_DIR,'document-alchemy-cli')).DocumentAlchemyCLI

describe "DocumentAlchemyCLI",->

  it "exists and has a main method",(done)->
    should.exist DocumentAlchemyCLI
    should.exist DocumentAlchemyCLI.main
    done()

  it "can enumerate commands",(done)->
    command_dir = path.join(LIB_DIR,"commands")
    da = new DocumentAlchemyCLI()
    da._list_commands command_dir, (err,commands)=>
      ("capture" in commands).should.be.ok
      ("convert" in commands).should.be.ok
      ("qrcode" in commands).should.be.ok
      ("_base-command" in commands).should.not.be.ok
      done()
