#!/bin/zsh
# Copies the rendered screenshots and the Play graphics into the fastlane folders.
set -eu
DIR=${0:A:h}
IOS=$DIR/../ios/fastlane/screenshots/de-DE
PLAY=$DIR/../android/fastlane/metadata/android/de-DE/images

rm -rf $IOS $PLAY/phoneScreenshots
mkdir -p $IOS $PLAY/phoneScreenshots
cp $DIR/out/ios/*.png $IOS/
cp $DIR/out/android/*.png $PLAY/phoneScreenshots/
cp $DIR/play/icon.png $PLAY/icon.png
cp $DIR/play/feature_graphic.png $PLAY/featureGraphic.png
echo "copied to $IOS and $PLAY"
