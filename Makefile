################################################################################
# META #########################################################################
################################################################################
.SUFFIXES:
.PHONY: all coffee clean clean-coverage clean-docco clean-docs clean-js clean-markdown clean-module clean-node-modules coverage docco docs fully-clean-node-modules js markdown test spec
all: full-lint test
clean: clean-coverage clean-docco clean-docs clean-js clean-node-modules
really-clean: clean really-clean-node-modules
################################################################################

################################################################################
# COFFEE & NODE ################################################################
################################################################################
COFFEE_EXE ?= ./node_modules/.bin/coffee
NODE_EXE ?= node
COFFEE_COMPILE ?= $(COFFEE_EXE) -c
COFFEE_COMPILE_ARGS ?=
COFFEE_SRCS ?= $(wildcard *.coffee lib/*.coffee lib/*/*.coffee)
COFFEE_TEST_SRCS ?= $(wildcard test/*.coffee test/*/*.coffee)
COFFEE_JS ?= ${COFFEE_SRCS:.coffee=.js}
COFFEE_TEST_JS ?= ${COFFEE_TEST_SRCS:.coffee=.js}
#------------------------------------------------------------------------------
coffee: $(NODE_MODULES)
	rm -rf $(LIB_COV)
js: coffee $(COFFEE_JS) $(COFFEE_TEST_JS)
.SUFFIXES: .js .coffee
.coffee.js:
	$(COFFEE_COMPILE) $(COFFEE_COMPILE_ARGS) $<
$(COFFEE_JS_OBJ): $(NODE_MODULES) $(COFFEE_SRCS) $(COFFEE_TEST_SRCS)
clean-js:
	@rm -f $(COFFEE_JS) $(COFFEE_TEST_JS)
################################################################################

################################################################################
# NPM ##########################################################################
################################################################################
NPM_EXE ?= npm
PACKAGE_JSON ?= package.json
NODE_MODULES ?= node_modules
NPM_ARGS ?= --silent
#------------------------------------------------------------------------------
$(NODE_MODULES): $(PACKAGE_JSON)
	$(NPM_EXE) $(NPM_ARGS) prune
	$(NPM_EXE) $(NPM_ARGS) install
	touch $(NODE_MODULES)
install: $(NODE_MODULES)
INSTALL:
	touch $(PACKAGE_JSON)
	make install
really-clean-node-modules:
	@rm -rf $(NODE_MODULES)
clean-node-modules:
	@$(NPM_EXE) $(NPM_ARGS) prune &
################################################################################

################################################################################
# JSHINT & COFFEELINT ##########################################################
################################################################################
COFFEE_JSHINT_EXE ?= ./node_modules/.bin/coffee-jshint
COFFEE_JSHINT_ARGS ?= -o 'node,mocha,evil'
COFFEELINT_EXE ?= ./node_modules/.bin/coffeelint
COFFEELINT_CONFIG ?= ./coffeelint.json
COFFEELINT_ARGS ?= -f $(COFFEELINT_CONFIG)
#------------------------------------------------------------------------------
coffee-jshint: $(PACKAGE_JSON) $(NODE_MODULES) $(COFFEE_SRCS) $(MOCHA_TESTS)
	$(COFFEE_JSHINT_EXE) $(COFFEE_JSHINT_ARGS) $(COFFEE_SRCS) $(MOCHA_TESTS)
jshint: coffee-jshint
hint: coffee-jshint

coffeelint: $(PACKAGE_JSON) $(NODE_MODULES) $(COFFEE_SRCS) $(MOCHA_TESTS)
	$(COFFEELINT_EXE) $(COFFEELINT_ARGS) $(COFFEE_SRCS) $(MOCHA_TESTS)
lint: coffeelint

full-lint: jshint lint

################################################################################
# TESTS ########################################################################
################################################################################
MOCHA_EXE ?= ./node_modules/.bin/mocha
TEST ?= $(wildcard test/test-*.coffee) $(wildcard test/*/test-*.coffee)
MOCHA_TESTS ?= $(TEST)
MOCHA_TEST_PATTERN ?=
MOCHA_TIMEOUT ?=-t 2000
MOCHA_TEST_ARGS  ?= -R list --compilers coffee:coffee-script/register $(MOCHA_TIMEOUT) $(MOCHA_TEST_PATTERN)
MOCHA_EXTRA_ARGS ?=
#------------------------------------------------------------------------------
LIB ?= lib
LIB_COV ?= lib-cov
COVERAGE_REPORT ?= docs/coverage.html
COVERAGE_TMP_DIR ?=  ./cov-tmp
COVERAGE_EXE ?= ./node_modules/.bin/coffeeCoverage
COVERAGE_ARGS ?= -e migration --initfile $(LIB_COV)/coffee-coverage-init.js
MOCHA_COV_ARGS  ?= --require $(LIB_COV)/coffee-coverage-init.js --globals "_\$$jscoverage" --compilers coffee:coffee-script/register -R html-cov -t 20000
#------------------------------------------------------------------------------
JASMINE_EXE ?= ./node_modules/.bin/jasmine-node
SPEC ?= $(wildcard spec/*-spec.coffee)
JASMINE_SPECS ?= $(SPEC)
JASMINE_ARGS  ?= --coffee
#------------------------------------------------------------------------------
test-all: $(MOCHA_TESTS) $(NODE_MODULES) $(PACKAGE_JSON)
	RUN_UNOCONV_TESTS=true RUN_WATERMARK_TESTS=true $(MOCHA_EXE) $(MOCHA_TEST_ARGS) ${MOCHA_EXTRA_ARGS} $(MOCHA_TESTS)
test: $(MOCHA_TESTS) $(NODE_MODULES) $(PACKAGE_JSON)
	@$(MOCHA_EXE) $(MOCHA_TEST_ARGS) ${MOCHA_EXTRA_ARGS} $(MOCHA_TESTS)
test-watch: $(MOCHA_TESTS) $(NODE_MODULES)
	$(MOCHA_EXE) --watch $(MOCHA_TEST_ARGS) ${MOCHA_EXTRA_ARGS} $(MOCHA_TESTS)
coverage: $(COFFEE_SRCS) $(COFFEE_TEST_SRCS) $(MOCHA_TESTS) $(NODE_MODULES)
	rm -rf $(COVERAGE_TMP_DIR)
	rm -rf $(LIB_COV)
	mkdir -p $(COVERAGE_TMP_DIR)
	cp -r $(LIB)/* $(COVERAGE_TMP_DIR)/.
	$(COVERAGE_EXE) $(COVERAGE_ARGS) $(COVERAGE_TMP_DIR) $(LIB_COV)
	mkdir -p `dirname $(COVERAGE_REPORT)`
	$(MOCHA_EXE) $(MOCHA_COV_ARGS) $(MOCHA_TESTS) > $(COVERAGE_REPORT)
	rm -rf $(COVERAGE_TMP_DIR)
	rm -rf $(LIB_COV)
clean-coverage:
	@rm -rf $(JSCOVERAGE_TMP_DIR)
	@rm -rf $(LIB_COV)
	@rm -f $(COVERAGE_REPORT)
clean-docs: clean-markdown clean-docco
################################################################################

################################################################################
# DOCUMENTATION ################################################################
################################################################################
MARKDOWN_TOC ?= ./node_modules/.bin/toc
MARKDOWN_SRCS ?= $(shell find . -type f -name '*.md' | grep -v node_modules | grep -v module)
MARKDOWN_TOCED ?= ${MARKDOWN_SRCS:.md=.md-toc}
MARKDOWN_PROCESSOR ?= node -e "var h=require('highlight.js'),m=require('marked'),c='';process.stdin.on('data',function(b){c+=b.toString();});process.stdin.on('end',function(){m.setOptions({gfm:true,highlight:function(x,l){if(l){return h.highlight(l,x).value;}else{return x;}}});console.log(m(c))});process.stdin.resume();"
MARKDOWN_HTML ?= ${MARKDOWN_TOCED:.md-toc=.html}
MARKDOWN_PREFIX ?= "<html><head><style>`cat docs/styles/markdown.css`</style><body>"
MARKDOWN_SUFFIX ?= "</body></html>"
DOCCO_EXE ?= ./node_modules/.bin/docco
#------------------------------------------------------------------------------
docs: markdown docco api
.SUFFIXES: .md-toc .md
.md.md-toc:
	cp "$<" "$@"
	$(MARKDOWN_TOC) "$@"
$(MARKDOWN_TOCCED_OBJ): $(MARKDOWN_SRCS)
.SUFFIXES: .html .md-toc
.md-toc.html:
	(echo $(MARKDOWN_PREFIX) > $@) && (cat "$<" | $(MARKDOWN_PROCESSOR) | sed "s/<!-- toc -->/<div id=TofC>/"  | sed "s/<!-- toc stop -->/<div style=\"font-size: 0.9em; text-align: right\"><a href=\".\" >[up]<\/a> <a href=\"javascript:back(-1)\">[back]<\/a><\/div><\/div>/" >> $@) && (echo $(MARKDOWN_SUFFIX) >> $@)
$(MARKDOWN_HTML_OBJ): $(MARKDOWN_TOCCED_OBJ)
$(MARKDOWN_HTML): docs/styles/markdown.css
md: $(MARKDOWN_HTML) $(NODE_MODULES)
html: md
docco: $(COFFEE_SRCS) $(NODE_MODULES)
	rm -rf docs/docco
	mkdir -p docs
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it
	$(DOCCO_EXE) $(COFFEE_SRCS)
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it/docco
	mv docs-temporarily-renamed-so-docco-doesnt-clobber-it docs
.SUFFIXES: .coffee
.coffee:
	$(COFFEE_EXE) $< >  $@
clean-docco:
	@rm -rf docs/docco
clean-markdown:
	@rm -rf $(MARKDOWN_HTML)
	@rm -rf $(LITCOFFEE_HTML)
