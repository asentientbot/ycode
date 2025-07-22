@import AppKit;
@import Darwin;
@import ObjectiveC;

#pragma clang diagnostic ignored "-Wunused-getter-return-value"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// TODO: lol

#import "Utils.m"
#import "Xcode.m"

#import "SettingsMapping.h"
#import "Settings.h"
#import "Document.h"
#import "WindowController.h"
#import "Delegate.h"

#import "SettingsMapping.m"
#import "Settings.m"
#import "Document.m"
#import "WindowController.m"
#import "Delegate.m"

int main(int argc,char** argv)
{
	@autoreleasepool
	{
		restartIfNeeded(argv);
		linkXcode();
		
#ifdef iconMode
		Settings.reset;
		
		CGImageRef image=createAppIcon(getXcodeTheme().sourceTextBackgroundColor.CGColor,getXcodeTheme().sourcePlainTextColor.CGColor,getXcodeTheme().sourceTextCurrentLineHighlightColor.CGColor);
		NSURL* url=[NSURL fileURLWithPath:@"icon.png"];
		CGImageDestinationRef destination=CGImageDestinationCreateWithURL((CFURLRef)url,kUTTypePNG,1,NULL);
		CGImageDestinationAddImage(destination,image,NULL);
		CGImageDestinationFinalize(destination);
		
		CFRelease(image);
		CFRelease(destination);
#else
		NSApplication.sharedApplication.delegate=Delegate.alloc.init;
		NSApp.run;
#endif
	}
}
