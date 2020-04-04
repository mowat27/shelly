#!/bin/sh

SHELLY_HOME=${HOME}/.shelly
SHELLY_LAUNCHER="$SHELLY_HOME"/shelly

mkdir -p "$SHELLY_HOME"

cat > $SHELLY_LAUNCHER <<EOF
  echo "Usage: shelly command"
EOF
chmod +x $SHELLY_LAUNCHER

ln -s $SHELLY_LAUNCHER /usr/local/bin/shelly 