mkdir AppDir

cp -r build/linux/x64/debug/bundle/* ./AppDir

./appimage_builder.AppImage

mv ./The\ Puzzle\ Cell-latest-x86_64.AppImage build/The\ Puzzle\ Cell.AppImage

rm The\ Puzzle\ Cell-latest-x86_64.AppImage.zsync

rm -rd ./AppDir
rm -rd ./appimage-build