@import AppKit;
@import Darwin;
@import ObjectiveC;

#pragma clang diagnostic ignored "-Wunused-getter-return-value"
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// TODO: lol

#import "Utils.m"

#import "Xcode.h"
#import "SettingsMapping.h"
#import "Settings.h"
#import "Document.h"
#import "WindowController.h"
#import "Delegate.h"

#import "Xcode.m"
#import "SettingsMapping.m"
#import "Settings.m"
#import "Document.m"
#import "WindowController.m"
#import "Delegate.m"

int main(int argc,char** argv)
{
	@autoreleasepool
	{
#ifdef iconMode
		Settings.saveAppIcon;
#else
		[Xcode setupWithArgv:argv];
		
		NSApplication.sharedApplication.delegate=Delegate.alloc.init;
		NSApp.run;
#endif
	}
}
