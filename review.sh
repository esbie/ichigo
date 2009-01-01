# Generate an HTML file called review.html for pending changes
# For general code reviews, run:
# $ ./review.sh
# For unstaged, uncommitted changes:
# $ ./review.sh HEAD
# For staged, nearly commited changes:
# $ ./review.sh pending
# For general diffs:
# $ ./review file
#
# Review process:
# 1) Edit files.
# 2) Verify changes with `review.sh pending` or `review.sh HEAD`.
# 3) Commit changes.
# 4) Run `review.sh` and copy output from a browser into an email for review.
# 5) Emails exchanged, repeat steps 1-5 until code looks okay.
# 6) Checkout master, merge with approved refspec*
# 7) Push changes
#
# * Approved refspec should be from latest commit and visible at the top of the
#   review output: branch $branch @$refspec (and the top of `git log`)



# Preferences
DIFF_COMMAND="git diff"
DIFF_OPTIONS="--summary --stat -B -C -C --ignore-submodules --src-prefix=old: --dst-prefix=new: -p --color -U50"
DIFF_TARGET=""

# Provide some aliased arguments
if [ "$1" = "pending" ] || [ "$1" = "cached" ]
then
  DIFF_TARGET="--cached"
elif [ -z "$1" ] # Nothing given
then
  DIFF_TARGET="HEAD~ HEAD"
else # Use whatever was given
  DIFF_TARGET="$1"
fi

# use `git branch` to determine current branch
BRANCH=`git branch | sed -e '/^[^\*]/d;s#\*[ \t]*##g'`
REFSPEC=`git log -1 --pretty=oneline | sed 's/\([^ ]*\).*/\1/'`
HEADER="branch $BRANCH <small>@$REFSPEC</small>"
SUBHEAD="diff of '$DIFF_TARGET'"
SUMMARY="`git log master.. | sed 's#$#<br/>#g'`"

# Run diff, encode < and >, convert colors to HTML, postprocess HTML
$DIFF_COMMAND $DIFF_OPTIONS $DIFF_TARGET | sed '
s#<#\&lt;#g;
s#>#\&gt;#g;
' | ./ansi2html.sh "$HEADER" "$SUBHEAD" "$SUMMARY" | sed '
# Wrap each code block with a <h2>FILENAME</h2> and give a background color.
s#^\(<span[^>]*>diff .*old:\(.*\) new:.*\)$#</div><h2>\2</h2>\1<div style="background-color:\#EEEEEE">#g;
' > review.html

# Open if command is present and review.html is not empty
if [ -n "`which open`" ] && [ -n "`cat review.html`" ]
then
  open review.html
  sleep 2
  rm review.html
fi
