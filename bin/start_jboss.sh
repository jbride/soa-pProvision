#!/bin/sh

SERVER_NAME=default-spp
cd $JBOSS_HOME/bin
rm nohup.out
chmod 755 run.sh
nohup ./run.sh -b $HOSTNAME -c $SERVER_NAME &

if test "x$1" = "xlog"
then
    sleep 15 
    tail -f $JBOSS_HOME/server/$SERVER_NAME/log/server.log
else
    echo "started but won't tail $SERVER_NAME/log/server.log"
fi
