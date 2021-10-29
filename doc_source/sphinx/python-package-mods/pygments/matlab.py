"""
    pygments.styles.matlab
    ~~~~~~~~~~~~~~~~~~~~~

    A highlighting style for Pygments, inspired by Matlab.

    :copyright: None.
    :license: Nope.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class MatlabStyle(Style):
    """
    A style mimicking the MATLAB editor.
    """

    background_color = "#ffffff"
    default_style = "emacs"

    styles = {
        Whitespace:                "#bbbbbb",

        Comment:                   "#008000",
        Comment.Preproc:           "#0000ff",
        Comment.Special:           "#008000",

        Keyword:                   "#0000ff",
        Keyword.Pseudo:            "#0000ff",
        Keyword.Type:              "#2b91af",

        Operator:                  "#0000ff",
        Operator.Word:             "#0000ff",

        Name.Class:                "#2b91af",

        String:                    "#a31515",
        String.Doc:                "#a31515",
        String.Interpol:           "#a31515",
        String.Escape:             "#a31515",
        String.Regex:              "#a31515",
        String.Symbol:             "#a31515",
        String.Other:              "#a31515",

        Generic.Heading:           "bold",
        Generic.Subheading:        "bold",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold",

        Error:                     "border:#FF0000"
    }
