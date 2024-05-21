set -e
cd "$(dirname "$0")"

name=Ycode
id=website.amys.ycode2
class=Document
type=public.text
minVersion=10.13

rm -rf "$name.app" "$name.zip"
mkdir -p "$name.app/Contents/MacOS"
mkdir -p "$name.app/Contents/Resources"

clang -fmodules -Wno-unused-getter-return-value -Wno-objc-missing-super-calls -mmacosx-version-min=$minVersion -DgitHash=$(git log -1 --format=%H) main.m -o "$name.app/Contents/MacOS/$name"

clang -fmodules -Wno-deprecated-declarations icon.m -o icon
./icon
rm -rf icon.iconset
mkdir icon.iconset
for size in 16 32 128 256 512
do
	sips -Z $size icon.png --out icon.iconset/icon_${size}x${size}.png
	sips -Z $(($size*2)) icon.png --out icon.iconset/icon_${size}x${size}@2x.png
done
iconutil -c icns icon.iconset -o "$name.app/Contents/Resources/Icon.icns"

echo "add CFBundleExecutable string $name
add CFBundleIdentifier string $id
add CFBundleIconFile string Icon.icns
add NSHighResolutionCapable bool true
add CFBundleDocumentTypes array
add CFBundleDocumentTypes:0 dict
add CFBundleDocumentTypes:0:NSDocumentClass string $class
add CFBundleDocumentTypes:0:CFBundleTypeRole string Editor
add CFBundleDocumentTypes:0:LSItemContentTypes array
add CFBundleDocumentTypes:0:LSItemContentTypes:0 string $type" | while read command
do
	/usr/libexec/PlistBuddy "$name.app/Contents/Info.plist" -c "$command"
done

codesign -f -s - "$name.app"
zip -r "$name.zip" "$name.app"

set +e
rm -rf icon icon.png icon.iconset
defaults delete $id
"./$name.app/Contents/MacOS/$name"
