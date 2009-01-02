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
#
# TODO: Warning for exceeding 80th character column
# TODO: GMail wraps blocks in <divs> and breaks lines up. (using divs or ps with
#       our own <br> did not seem to help. GMail insists on adding gaps.)

# Preferences
DIFF_COMMAND="git diff"

DIFF_OPTIONS="--summary --stat -B -C -C --ignore-submodules
              --src-prefix=old: --dst-prefix=new: -p --color -U50"

DIFF_TARGET=""
# Provide some aliased arguments
if [ "$1" = "pending" ] || [ "$1" = "cached" ]
then
  DIFF_TARGET="--cached"
elif [ -z "$1" ]
then
  # Nothing given
  DIFF_TARGET="HEAD~ HEAD"
else
  # Use whatever was given
  DIFF_TARGET="$1"
fi

# Use `git symbolic-ref` to get branch name (comes back as ref/heads/BRANCH).
BRANCH="$(git symbolic-ref HEAD)"
# Remove leading ref/heads/
BRANCH="${BRANCH##refs/heads/}"
# Get the 40 byte hash for HEAD
REFSPEC=$(git rev-parse --verify HEAD)
# Find the common anscestor between us (HEAD) and master
ANSCESTOR=$(git merge-base master HEAD)
HEADER="branch $BRANCH <small>@$REFSPEC</small>"
SUBHEAD="diff of '$DIFF_TARGET'"
# Get an (html) log of all commit messages since $ANSCESTOR
SUMMARY=$(git log $ANSCESTOR.. | sed 's#$#<br/>#g')

# Run diff and...
$DIFF_COMMAND $DIFF_OPTIONS $DIFF_TARGET |

  # Encode < and >
  sed 's#<#\&lt;#g; s#>#\&gt;#g;' |

  # Encode ansi color codes into HTML (and print header, subhead, etc)
  ./ansi2html.sh "$HEADER" "$SUBHEAD" "$SUMMARY" |

  # Label each code block with <h2>FILENAME</h2> and give a background color.
  sed '
    s#^\(<span[^>]*>diff .*old:\(.*\) new:.*\)$#\
    </pre><h2>\2</h2>\1\
    <pre style="font-family:Andale Mono, Courier New, monospace;\
                font-size:13pt;background:\#F9F9F9">#g;' \
  > review.html

# Open if command is present and review.html is not empty
if [ -n "$(which open)" ] && [ -n "$(cat review.html)" ]
then
  open review.html
  sleep 2
  rm review.html
fi
