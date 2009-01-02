#!/bin/sh

# http://www.pixelbeat.org/docs/terminal_colours/
# slight modifications for git by Phil Harnish

echo "<head>
<style type=\"text/css\">
body { font-family: Helvetica, Arial, sans-serif; }
/* linux console palette */
.f0 { color: #000000; }
.f1 { color: #AA0000; }
.f2 { color: #00AA00; }
.f3 { color: #AA5500; }
.f4 { color: #0000AA; }
.f5 { color: #AA00AA; }
.f6 { color: #00AAAA; }
.f7 { color: #AAAAAA; }
.bf0 { color: #555555; }
.bf1 { color: #FF5555; }
.bf2 { color: #55FF55; }
.bf3 { color: #FFFF55; }
.bf4 { color: #5555FF; }
.bf5 { color: #FF55FF; }
.bf6 { color: #55FFFF; }
.bf7 { color: #FFFFFF; }
.b0 { background-color: #000000; }
.b1 { background-color: #AA0000; }
.b2 { background-color: #00AA00; }
.b3 { background-color: #AA5500; }
.b4 { background-color: #0000AA; }
.b5 { background-color: #AA00AA; }
.b6 { background-color: #00AAAA; }
.b7 { background-color: #AAAAAA; }
</style>
</head>

<html>
<body>"


# Header
if [ -n "$1" ]
then
  echo "<h1>$1</h1>"
fi

# Subhead
if [ -n "$2" ]
then
  echo "<small style='font-style: italic'>$2</small>"
fi

# Summary
if [ -n "$3" ]
then
  echo "<p>$3</p>"
fi

echo "<pre>"

cat -v |
#first line normalizes codes a little
sed '
s#\^\[\[1m\^\[\[\([34][0-7]m\)#^[[1;\1#; s#\^\[\[m#^[[0m#g; s#\^\[(B##g;
s#\^\[\[0m#</span>#g;
s#\^\[\[3\([0-7]\);4\([0-7]\)m#<span class="f\1 b\2">#g;
s#\^\[\[1;3\([0-7]\);4\([0-7]\)m#<span class="bf\1 b\2">#g;
# Force colored background in HTML output for red
s#\^\[\[41m#<span style="background-color:\#AA0000">#g;
s#\^\[\[4\([0-7]\)m#<span class="b\1">#g;
# These three force colors into the HTML output for red, green, teal
s#\^\[\[31m#<span style="color: \#AA0000;">#g;
s#\^\[\[32m#<span style="color: \#00AA00;">#g;
s#\^\[\[36m#<span style="color: \#00AAAA;">#g;
s#\^\[\[3\([0-7]\)m#<span class="f\1">#g;
s#\^\[\[1;3\([0-7]\)m#<span class="bf\1">#g;
s#\^\[\[1m#<span style="font-weight:bold">#g;'

echo "</pre>
</body>
</html>"
