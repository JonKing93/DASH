"""
    pygments.styles.matlab
    ~~~~~~~~~~~~~~~~~~~~~

    A highlighting style for Pygments, inspired by the Matlab editor

    :copyright: lol
    :license: nope
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class MatlabStyle(Style):
    """
    The style (inspired by the Matlab editor).
    """

    background_color = "#f8f8f8"
    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "#008800",
        Keyword:                   "#0000FF",
        String:                    "#A020F0"
    }
