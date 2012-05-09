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

Once it loads, you will get a blank buffer ready to be used with the loaded
text.


Movement or flow control
------------------------
Mappings to start and control the flow of the presentation are:

* *l* or <down> display next line in text
* *h* or <up> undo the last displayed line of text
* *L* or <right> <move to the next slide
* *H* or <left> move to the previous slide

Multiple slides
---------------
If you need to *clear* the screen for a new slide you just need to add
a delimeter. in ``Posero`` that means the `>` character repeated at least 80
times::

    this would be slide number one

    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    and this would be slide number two. You would not see any of the text
    from the first slide here.

Slide options
-------------
As you can imagine, all of this action is hapenning on real Vim buffers, so
``Posero`` harness into this by allowing you to set *any* type of valid Vim
options **per slide**. This is done with a simple syntax::

    POSERO>> echo "this will get executed when the slide loads!"

    this is some text on the slide. The above option will not appear here.

Fake Typing and output chunks
-----------------------------
To have a more realistic feel, you can enable *fake typing* on certain lines.
This is done by matching the line to a regular expression set by an option on
the actual slide.

Fake typing for lines that have a dollar sign for example would be enabled like 
this::

    POSERO>> let b:posero_fake_type = "^\$"

Every line that starts with a dollar sign would have fake typing on. All of the
rest would have an atomic display of the actual line. But that is just half of
the equation, the other half is to be able to display chunked output to mimic
executing commands and getting some output. But this is not enabled by default
when the fake typing is set.

The *normal* flow would be to output one line every time you hit the "next"
mapping (``l`` or ``<down>``) and undo a single line every time you hit the
"previous" mapping (``h`` or ``<up>``). Chunked output is a boolean option and
can be set like::

    POSERO>> let b:posero_push_on_non_fake = 1
