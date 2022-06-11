cp -r build/linux/x64/release/bundle/* ./AppDir

./appimage_builder.AppImage

mv ./The\ Puzzle\ Cell-latest-x86_64.AppImage build/The\ Puzzle\ Cell.AppImage

rm The\ Puzzle\ Cell-latest-x86_64.AppImage.zsync