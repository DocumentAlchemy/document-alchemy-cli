[![Build Status](https://travis-ci.org/documentalchemy/document-alchemy-cli.svg?branch=master)](https://travis-ci.org/documentalchemy/document-alchemy-cli) [![Dependencies](https://david-dm.org/documentalchemy/document-alchemy-cli.svg)](https://npmjs.org/package/document-alchemy-cli) [![NPM version](https://badge.fury.io/js/document-alchemy-cli.svg)](https://badge.fury.io/js/document-alchemy-cli)

## About This Module

`document-alchemy-cli` is a command-line interface to the [DocumentAlchemy document processing API](https://documentalchemy.com/api-doc).

For example, DocumentAlchemy has a REST method that will capture a &ldquo;screenshot&rdquo; of a web page, returning an image of the rendered page. To invoke that API method from the command-line using document-alchemy-cli, you may enter an command like the following:

     document-alchemy capture "https://google.com/" -o capture.png

This will generate a file named `capture.png` that contains an image of the Google homepage as captured in our virtualized browser.

The command-line interface accepts various configuration parameters, depending upon the specific action being taken.  For example, the command:


     document-alchemy capture "https://google.com/" -w 800 -h 600 -o capture.png

will capture the contents of google.com as seen in a web browser with a &ldquo;viewport&rdquo; that is 800 pixels wide and 600 pixels tall.


### Installing

The DocumentAlchemy command-line interface is built with JavaScript / Node.js.  You'll need a moderately recent version of Node.js (or IO.js) installed in order to run the application.  (Installing Node.js is quick and easy. Visit <https://nodejs.org/en/download> to download an installer for Windows, OSX, Linux and more).

Once Node is installed, you can install the DocumentAlchemy command-line application in one of two ways:

**To install using `npm`** simply execute `npm install document-alchemy-cli -g`.

**To install from source**, clone this repository, open a terminal to the root directory of that cloned repository and run `make install` or `npm install`.

This will install any external dependencies needed to run the application.

Unless you intend to extend or modify the CLI application, or want to use a pre-released version for some reason, we recommend that you install a &ldquo;stable release&rdquo; via the npm command.

### Running

Once installed, enter:

    document-alchemy --help

for information about how to use the application.

The command:

    document-alchemy <COMMAND> --help

will yield help on a given "sub-command" (such as `convert` or, as above, `capture`).

For even more information, use the flag `--xhelp` for &ldquo;extended&rdquo; help.

For even more information, review the documentation for the underlying REST methods at <https://documentalchemy.com/api-doc>, or visit us on the web at <https://documentalchemy.com/>.

**NOTE:** To make full use of the DocumentAlchemy command-line tool, you'll want to [sign up with DocumentAlchemy](https://documentalchemy.com/pricing?c=clid) to obtain your own API key.  However, the API key seen in the in-app examples is a real (limited-use) API key, in case you just want to get started right away.

### The Commands

The functionality of `document-alchemy` is divided into several "sub-commands":

 * **capture** - captures a &ldquo;screenshot&rdquo; of a web page (URL), returning an image of the web page running in a fully-featured virtualized browser.
 * **convert** - converts a document from one type to another, such as Word to HTML, Markdown to PDF, Word to Markdown, etc. Certain ldquo;special&rdquo; conversions are also supported, such as extracting all images from a PDF or MS Office document, or splitting a PDF document into individual pages.
 * **join** - combines two or more MS Office (Word, PowerPoint, Excel) and PDF documents into a single PDF file.
 * **qrcode** - generates an image of a QR code encoding the specified data.
 * **split** - split a PDF document into individual pages.
 * **transform** - modifies an image by resizing, cropping, rotating, flipping, blurring, sharpening or de-colorizing it.

Each command is documented within the application itself. For your convenience we have placed samples of the in-app help content within the `docs` directory.

Specifically, you'll find the "extended help" message for [the main application](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-main.md#extended-help-for-the-documentalchemy-cli), the [capture command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-capture.md#extended-help-for-the-capture-command), the [convert command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-convert.md#extended-help-for-the-convert-command),  the [join command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-join.md#extended-help-for-the-join-command), the [qrcode command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-qrcode.md#extended-help-for-the-qrcode-command), the [qrcode command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-split.md#extended-help-for-the-split-command) and the [transform command](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/docs/xhelp-transform.md#extended-help-for-the-transform-command) in the `docs` directory.


### Configuration

While not strictly necessary, we recommend that you save yourself the trouble of entering your API key every time you want to use the  DocumentAlchemy command-line tool by storing your key (and if you prefer, other options) in a configuration file.

To store your key in a configuration file, create the file `.documentalchemycli.json` in either (a) your home directory or (b) the &ldquo;working directory&rdquo; from which you are running the application (or both). Add to the file:

```json
{
  "api-key":"MY-API-KEY"
}
```

(replacing `MY-API-KEY` with your actual API key).  Now whenever you invoke `document-alchemy` there will be an implicit `--api-key MY-API-KEY` parameter included automatically.

In fact, you can verify this by running `document-alchemy --help` and noting that the API key value you entered is now listed as the default value for `--api-key`.

Note that any parameters you specify on the command-line itself will take precedence over those found in a configuration file, and that values specified in the configuration file in the local working directory will take precedence over those found in the configuration file in your home directory.


### Licensing

This module is made available under an MIT license, as described in [LICENSE.TXT](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/LICENSE.TXT).

Your feedback, suggestions and pull-requests are welcome and appreciated.

## About DocumentAlchemy

Document Alchemy provides an easy-to-use API for generating, transforming, converting and processing documents in various formats, including:

 * MS Office documents such as Microsoft Word, Excel and PowerPoint.
 * Open source office documents such Apache OpenOffice Writer, Calc and Impress.
 * Adobe's Portable Document Format (PDF)
 * HTML, Markdown and other text formats
 * Images such as PNG, JPEG, GIF and others.

More information, [free, online demonstrations of our document conversion tools](https://documentalchemy.com/demo), and interactive documentation of our [RESTful document processing API](https://documentalchemy.com/api-doc) can be found at <https://documentalchemy.com>.

You can follow us on Twitter at [@DocumentAlchemy](http://twitter.com/DocumentAlchemy).

![](https://documentalchemy.com/images/beakers-61x64.png)
