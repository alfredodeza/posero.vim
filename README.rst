Posero
======

Presentation (replay!) of text or terminal action in Vim. Copy any kind of text
from the terminal into a file and use ``Posero`` or use *any* kind of plain
text file to use it as presentation material.

Why oh why?
-----------
I researched a bunch of terminal recording applications including ``ttyrec``
but all of them lacked the ability to all of these features I wanted:

* Be able to start/stop/rewind/forward/clear a session.
* Post editing (a few apps saved their output to a binary). Nothing better than
  plain text files.
* Add notes to actual output, like comments.
* Arbitrary, powerful syntax highlighting *adpated to your color scheme*.
* Custom specific options per slide.
* Add custom syntax to non-syntax output (for example: curl output)

Basic usage
-----------
The simplest way to get started, once the plugin is installed, is by calling
the plugin and pass in a file as an argument.

Lets assume we have the following output from our terminal and we have saved it
as ``terminal_test.txt`` ::

     /tmp $ cd
     ~ $ cd /var
     /var $ cd log 
     /var/log $ ls | grep apache
     apache2
     /var/log $ 

To execute this as a "presentation" you would start vim and type the path to
that file::

    :Posero terminal_test.txt

Once it loads, you will get a blank buffer. 

Mappings to start and control the flow of the presentation are:

* *l* or <down> display next line in text
* *h* or <up> undo the last displayed line of text
* *L* or <right> <move to the next slide
* *H* or <left> move to the previous slide
