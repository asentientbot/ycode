set -e
cd "$(dirname "$0")"

name=Ycode
id=website.amys.ycode2
class=Document
type=public.data
minVersion=10.13

if [[ $1 == test ]]
then
	name+=' Test'
	id+=-test
fi

rm -rf "$name.app" "$name.zip" icon.iconset
mkdir -p "$name.app/Contents/MacOS"
mkdir -p "$name.app/Contents/Resources"

clang -fmodules -mmacosx-version-min=$minVersion -arch x86_64 -arch arm64 -DgitHash=$(git log -1 --format=%H) main.m -o "$name.app/Contents/MacOS/$name"

clang -fmodules -D iconMode main.m -o icon
./icon

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
add CFBundleDocumentTypes: dict
add CFBundleDocumentTypes:0:NSDocumentClass string $class
add CFBundleDocumentTypes:0:CFBundleTypeRole string Editor
add CFBundleDocumentTypes:0:LSItemContentTypes array
add CFBundleDocumentTypes:0:LSItemContentTypes: string $type
add NSSupportsAutomaticTermination bool true" | while read command
do
	/usr/libexec/PlistBuddy "$name.app/Contents/Info.plist" -c "$command"
done

codesign -f -s - "$name.app"
zip -r "$name.zip" "$name.app"

rm -rf icon icon.png icon.iconset ~'/Library/Developer/Xcode/UserData/FontAndColorThemes/icon.xccolortheme'

if [[ $1 != test ]]
then
	exit
fi

set +e

defaults delete $id
rm ~"/Library/Developer/Xcode/UserData/FontAndColorThemes/$name.xccolortheme"

"$name.app/Contents/MacOS/$name"
