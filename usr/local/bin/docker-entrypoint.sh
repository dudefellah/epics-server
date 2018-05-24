#!/bin/sh

cd $WORK_DIR/softioc/iocBoot/$SOFT_IOC_NAME

/tini -v -- $WORK_DIR/softioc/bin/linux-$(uname -m)/$SOFT_IOC_NAME st.cmd $*
