#!/bin/bash

# user enable to run script :: root

# When logged in as user  root, making a single mistake can
# damage or destroy a system. Therefore, we recommend building
# the packages in this chapter as an unprivileged user.

groupadd lfs										|| exit 1
useradd -s /bin/bash -g lfs -m -k /dev/null lfs		|| exit 1
