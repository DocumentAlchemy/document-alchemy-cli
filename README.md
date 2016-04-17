## About This Module

`document-alchemy-cli` is a command-line interface to the [DocumentAlchemy document processing API](https://documentalchemy.com/api-doc).

As an example, one simple DocumentAlchemy API method will generate a QR code. To invoke that REST method from the command line using `document-alchemy-cli`, you may enter an command like the following:

     document-alchemy qrcode "Hello World!" -o hello.png

This will generate a file named `hello.png` that contains an image of a QR code encoding the text "Hello World!".

### Installing

**To install using `npm`** simply execute `npm install document-alchemy-cli -g`.

**To install from source**, clone this repository, open a terminal to the root directory of that cloned repository and run `make install` or `npm install`.

This will install any external dependencies needed to run the application.

### Running

Once installed, enter:

    document-alchemy --help

for information about how to use the application.

The command:

    document-alchemy <COMMAND> --help

will yield help on a given "sub-command" (such as `convert` or, as above, `qrcode`).

For even more information, use the flag `--xhelp` rather than just `--help`.

For even more information, visit us at <https://documentalchemy.com/>

### The Commands

The functionality of `document-alchemy` is divided into several "sub-commands".  Currently there are three sub-commands provided: `convert`, `qrcode` and `capture`.


### Licensing

This module is made available under an MIT license, as described in [LICENSE.TXT](https://github.com/DocumentAlchemy/document-alchemy-cli/blob/master/LICENSE.TXT).

## About DocumentAlchemy

Document Alchemy provides an easy-to-use API for generating, transforming, converting and processing documents in various formats, including:

 * MS Office documents such as Microsoft Word, Excel and PowerPoint.
 * Open source office documents such Apache OpenOffice Writer, Calc and Impress.
 * Adobe's Portable Document Format (PDF)
 * HTML, Markdown and other text formats
 * Images such as PNG, JPEG, GIF and others.

More information, [free, online demonstrations of our document conversion tools](https://documentalchemy.com/demo), and interactive documentation of our [RESTful document processing API](https://documentalchemy.com/api-doc) can be found at <https://documentalchemy.com>.

You can follow us on Twitter at [@DocumentAlchemy](http://twitter.com/DocumentAlchemy).
