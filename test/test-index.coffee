should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join(__dirname,'..')
LIB_DIR   = if fs.existsSync(path.join(HOMEDIR,'lib-cov')) then path.join(HOMEDIR,'lib-cov') else path.join(HOMEDIR,'lib')

describe "index",->

  it "exists and has a main method",(done)->
    index = require(path.join(LIB_DIR,'index'))
    should.exist index
    should.exist index.DocumentAlchemyCLI
    should.exist index.main
    done()
