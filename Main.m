@import AppKit;
@import Darwin;
@import ObjectiveC;
@import MachO;
#define trace NSLog

// TODO: lol

#import "Utils.m"
#import "Setup.m"
#import "AmyDocument.h"
#import "AmyWindowController.h"
#import "AmyDelegate.h"
#import "AmyDocument.m"
#import "AmyWindowController.m"
#import "AmyDelegate.m"

int main(int argc,char** argv)
{
	startup(argc,argv);
	
	NSApplication.sharedApplication.delegate=AmyDelegate.alloc.init;
	NSApp.run;
}
