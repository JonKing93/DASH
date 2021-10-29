dash.assert
===========
Functions that assert inputs meet required conditions

The dash.assert subpackage facilitates the creation of informative error messages and helps provide consistent error ID handling for common input error checks. These functions produce error messages that appear to originate from higher level calling functions.

Some functions also return inputs converted to specific formats to ensure consistent internal handling of different input types.


.. raw:: html

    <h3>Strings</h3>

.. rst-class:: package-links

| :doc:`strflag <assert/strflag>` - Throw error if input is not a string flag.
| :doc:`strlist <assert/strlist>` - Throw error if input is not a string vector, cellstring vector, or char row vector
| :doc:`strsInList <assert/strsInList>` - Throw error if strings are not in a list of allowed strings

.. toctree::
    :hidden:

    strflag <assert/strflag>
    strlist <assert/strlist>
    strsInList <assert/strsInList>


.. raw:: html

    <h3>Size and Data Type</h3>

.. rst-class:: package-links

| :doc:`type <assert/type>` - Throw error if input is not required type
| :doc:`scalarType <assert/scalarType>` - Throw error if input is not a scalar of a required data type
| :doc:`vectorTypeN <assert/vectorTypeN>` - Throw error if input is not a vector of required data type and length

.. toctree::
    :hidden:

    type <assert/type>
    scalarType <assert/scalarType>
    vectorTypeN <assert/vectorTypeN>


.. raw:: html

    <h3>Files</h3>

.. rst-class:: package-links

| :doc:`fileExists <assert/fileExists>` - Throw error if a file does not exist

.. toctree::
    :hidden:

    fileExists <assert/fileExists>


.. raw:: html

    <h3>Tests</h3>

.. rst-class:: package-links

| :doc:`tests <assert/tests>` - Implement unit testing for the dash.assert subpackage

.. toctree::
    :hidden:

    tests <assert/tests>
