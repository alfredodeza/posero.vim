posero.vim
==========
**follow @alfredodeza for updates**

Presentation (replay!) of text or terminal action in Vim. Copy any kind of text
from the terminal into a file and use ``Posero`` or use *any* kind of plain
text file to use it as presentation material.

I consider this plugin as pre-alpha status, that is, I have it in an utterly
inconsistent state where I keep breaking it. Try it out, let me know what
you think and send me some feedback, but do realize this is still work in
progress.


Short screencast: http://www.youtube.com/watch?v=BtlxLAuWn3A

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

Get started
-----------
The simplest way to get started, once the plugin is installed, is by calling
the plugin and pass in a file as an argument.

**make sure you set default mappings**

In your .vimrc::

    let g:posero_default_mappings = 1

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
text. Just hit ``Ctrl-l`` and see what happens!

For more options, tweaks, syntax and flow control, read below.


Movement or flow control
------------------------
Mappings have to be enabled, so **make sure** you have the following flag
set on your ``.vimrc``::

    let g:posero_default_mappings = 1

To just use your own mappings and disable the default ones set the value to
zero::

    let g:posero_default_mappings = 0

If you do not have any mappings and are not enabling or turning off the
setting, the plugin will warn you about this problem.

These are the default mappings for the plugin:

* Ctrl-h   = Previous slide
* Ctrl-j   = Next line
* Ctrl-k   = Previous line
* Ctrl-l   = Next slide

If you don't like those, you can set your own custom mappings as the plugin
allows calls to the functions that control the flow of the presentation. This
is how you would map arrow keys for the length of the presentation::

    nnoremap <silent> <buffer> <up>    :call posero#PreviousLine()<CR>
    nnoremap <silent> <buffer> <down>  :call posero#NextLine()<CR>
    nnoremap <silent> <buffer> <right> :call posero#NextSlide()<CR>
    nnoremap <silent> <buffer> <left>  :call posero#PreviousSlide()<CR>

You can obviously map these to any key combination you want, the above are only
suggestions.


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

All slide options are reset from one slide to another, so unless you are making
system-wide changes (like setting the filetype to something different) you need
to set them again to have the same behavior, this avoids *sticky* options where
previous slide options are applied for the current one.


"Normal" slide
--------------
If you want old fashioned slides that output a bunch of text all at once as
soon as you get to a given slide, you need 2 options playing together::

    POSERO>> let b:posero_auto_next_line = 1
    POSERO>> let b:posero_push_all = 1

The ``auto_next_line`` option tells the plugin to trigger a call to the next
line, which in turn realizes that ``push_all`` is set and it will get
everything on that slide printed at once.


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


Fake Type Everything
--------------------
You could also *fake type* the whole slide. To accomplish this you would need
to set ``b:posero_fake_type`` and ``b:posero_push_all`` on the slide like
this::

    POSERO>> let b:posero_push_all = 1
    POSERO>> let b:posero_fake_type = '\v(.*)'

This will go through every line and matching fake typing but will continue to
push lines because ``b:posero_push_all`` is set.

Custom syntax
-------------
This plugin comes with a directory for custom syntax files called
``posero_syntax`` and it should be at the top level of the plugin directory
with a few examples on how they should look like. If you just saved an IPython
session and want to use the custom syntax bundled with this plugin you would
set it like this on the slide::

    POSERO>> let b:posero_syntax = "ipython"

As you may notice, the name of the syntax is the same as the first portion of
the syntax file (in this case, called ``ipython.vim``). Any new syntax files
would have to follow that pattern. For example, if you have one for ``curl``
you would need to add a ``posero_syntax/curl.vim`` file and then do::

    POSERO>> let b:posero_syntax = "curl"

Having the ability for custom syntax highlighting is nice, but remember,
``Posero`` allows you to do real Vim syntax and options, so if you are
presenting a pure Python file you could just set the filetype to python::

    POSERO>> set filetype=python

That is also useful if you are changing from some Python to RestructuredText on
the next slide, and you want RST syntax there. ``Posero`` will call those
options on every slide change so your changes are set before anything is
displayed.

Posero syntax
-------------
``Posero`` has its own syntax highlighting. This is automatically set for you
if you are naming your presentation file with the ``.posero`` extension.

StatusLine
----------
A very basic status line is set by default with the current line number, total
line numbers of the current slide on the left and the slide number with the
total slide numbers on the right::

    Line:[1/18]                                         Slide:[1/4]

The name
--------
The name comes from peruvian slang, that basically means "show off". You do
want to show of your terminal action, don't you?
