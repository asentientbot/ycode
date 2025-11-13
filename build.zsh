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

clang -fmodules -mmacosx-version-min=$minVersion -arch x86_64 -arch arm64 -D YcodeAppName="$name" -D YcodeGitHash=$(git log -1 --format=%H) main.m -o "$name.app/Contents/MacOS/$name"

clang -fmodules -D YcodeBuildMode -D YcodeAppName="$name" main.m -o helper
./helper

mkdir icon.iconset
for size in 16 32 128 256 512
do
	sips -Z $size icon.png --out icon.iconset/icon_${size}x${size}.png
	sips -Z $(($size*2)) icon.png --out icon.iconset/icon_${size}x${size}@2x.png
done
iconutil -c icns icon.iconset -o "$name.app/Contents/Resources/Icon.icns"

rm -r helper icon.png icon.iconset

while read line
do
	/usr/libexec/PlistBuddy "$name.app/Contents/Info.plist" -c "$line"
done <<< "add CFBundleExecutable string $name
add CFBundleIdentifier string $id
add CFBundleIconFile string Icon.icns
add CFBundleDocumentTypes array
add CFBundleDocumentTypes: dict
add CFBundleDocumentTypes:0:NSDocumentClass string $class
add CFBundleDocumentTypes:0:CFBundleTypeRole string Editor
add CFBundleDocumentTypes:0:LSItemContentTypes array
add CFBundleDocumentTypes:0:LSItemContentTypes: string $type
add NSHighResolutionCapable bool true
add NSSupportsAutomaticTermination bool true"

codesign -fs - "$name.app"

if [[ $1 == test ]]
then
	set +e
	
	defaults delete $id
	
	"$name.app/Contents/MacOS/$name"
else
	zip -r "$name.zip" "$name.app"
fi
