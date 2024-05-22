@import AppKit;
@import Darwin;
@import ObjectiveC;
@import MachO;
#define trace NSLog

// TODO: lol

#import "Utils.m"
#import "Xcode.m"

#import "SettingsMapping.h"
#import "ThemeMapping.h"
#import "Settings.h"
#import "Document.h"
#import "WindowController.h"
#import "Delegate.h"

#import "SettingsMapping.m"
#import "ThemeMapping.m"
#import "Settings.m"
#import "Document.m"
#import "WindowController.m"
#import "Delegate.m"

int main(int argc,char** argv)
{
	restartIfNeeded(argv);
	linkXcode();
	
	NSApplication.sharedApplication.delegate=Delegate.alloc.init;
	NSApp.run;
}
