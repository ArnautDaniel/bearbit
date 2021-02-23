needs imports/gforth-raylib/raylib3.fs

(

Welcome to Bearbit, a Gforth/Raylib powered fantasy console inspired by
pico-8 and retro-40.  Bearbit gives you a standard 256x256 [upscaled to 768x768]
screen, with 64px of your height being dedicated to a status line.  This leaves you
with a true 256x256 screen and a free place for info/dialogue [64px status-box].

Let's start by defining that.

)

256 constant screen-box
64 constant status-box \ Offset for where our status-box ends
768 constant window-width \ Our upscaled window
768 constant window-height
3 constant bear-scale \ the renderer will scale our draw calls to fit 768x768

(

We also want to setup our 256x256 area of memory.  We'll send an integer to
any cell in this region to determine which color is drawn by the rendering
loop.  Text in the status bar will be handled different but let's first
consider our main box.

 _ _ _ _ _ _ _ _
|-|-|-|-|-|-|-|-|
|-|-|-|-|-|-|-|-|
|-|-|-|-|-|-|-|-|     MAIN BOX
|-|-|-|-|-|-|-|-|  
|-|-|-|-|-|-|-|-|
-----------------
|-|-|-|-|-|-|-|-|     STATUS BOX
|-|-|-|-|-|-|-|-| 
-----------------

Every "-" will denote a cell in memory that represents the color of
that particular XY coordinate.

)

: bearscreen: ( -- ) create ; 
: ;bearscreen ( x y -- offset-addr )
  does>
    2 pick cells screen-box * ( x * screen-box )
    ( x y addr offset ) + ( x y offset-addr)
    swap cells + ( x offset-addr )
    swap drop ;

( Initialize a bearscreen to fully black )
: bearvectors 0 do black , loop ;

( Now we can create our memory area for our screen )
bearscreen: bearscreen screen-box screen-box * bearvectors ;bearscreen

(

bearscreen will be a global value holding the start of our 256x256 array of
memory.  We can use this to write words that update the data inside the array
thus changing what is drawn.

We'll use "i" as a prefix for any internal words.  Let's write a generic word
that can let us fill our area of memory with arbitrary colors.

)

: ibearfill ( x y color -- )
    screen-box 0 do
	screen-box 0 do
    j i bearscreen over swap ! over +loop 2 pick +loop 2drop drop ;

: bearfill ( color -- )
    1 1 rot ibearfill ;

: bearlineV ( y color -- )
    1 -rot ibearfill  ;

: bearlineH ( x color -- )
    1 swap ibearfill ;

: bearscale ( x y -- )
    bear-scale * swap
    bear-scale * swap ;

: beardraw ( -- )
     screen-box  0 do
	 screen-box 0 do
	    j i 
	    2dup bearscreen @ >r
     bearscale bear-scale dup r> drawrectangle loop loop ;
 
: bearrender ( -- )
    begindrawing beardraw enddrawing ; 

: init-bearbit
    window-width window-height s" BearBit Fill" initwindow
    30 settargetfps bearrender ;
    

