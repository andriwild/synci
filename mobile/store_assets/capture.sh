#!/bin/zsh
# Captures the raw store screenshots with demo data into screens/<platform>/.
# Usage: ./capture.sh ios <simulator-udid> | ./capture.sh android <adb-serial>
set -eu

PLATFORM=$1
DEVICE=$2
DIR=${0:A:h}
OUT=$DIR/screens/$PLATFORM
LOG=$(mktemp -t synci-capture)
ADB=${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb
mkdir -p $OUT

if [[ $PLATFORM == ios ]]; then
  xcrun simctl status_bar $DEVICE override --time 9:41 --batteryState charged --batteryLevel 100 \
    --cellularMode active --cellularBars 4 --wifiBars 3 --operatorName ''
  shot() { xcrun simctl io $DEVICE screenshot $OUT/$1.png >/dev/null }
else
  $ADB -s $DEVICE shell settings put global sysui_demo_allowed 1
  demo() { $ADB -s $DEVICE shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null }
  demo enter
  demo clock -e hhmm 0941
  demo battery -e level 100 -e plugged false
  demo network -e wifi show -e level 4 -e mobile show -e datatype none -e level 4
  demo notifications -e visible false
  shot() { $ADB -s $DEVICE exec-out screencap -p > $OUT/$1.png }
fi

cd $DIR/..
flutter run -t test_driver/screenshots.dart -d $DEVICE --dart-define-from-file=config/dev.json > $LOG 2>&1 &
FLUTTER=$!
trap 'kill $FLUTTER 2>/dev/null; [[ $PLATFORM == android ]] && demo exit' EXIT

tail -n +1 -F $LOG | while read -r line; do
  case $line in
    *'SHOT done'*) pkill -f -- "-F $LOG"; break ;;
    *'SHOT '*) name=${line##*SHOT }; shot $name; echo "captured $OUT/$name.png" ;;
    *'Error:'*|*'FAILURE'*) echo $line >&2; exit 1 ;;
  esac
done
