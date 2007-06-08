Continuous Builder
=================

Continuous integration made trivial.

Subversion post-commit hook:

DEVELOPERS=david@loudthinking.com
BUILDER="'Continuous Builder' <cb@37signals.com>"

cd /u/apps/your/app    && /usr/local/bin/rake -t test_latest_revision NAME=YourApp RECIPIENTS="$DEVELOPERS" SENDER="$BUILDER" &
cd /u/apps/another/app && /usr/local/bin/rake -t test_latest_revision NAME=AnotherApp RECIPIENTS="$DEVELOPERS" SENDER="$BUILDER" &