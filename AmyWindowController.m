// TODO: uhh

@interface AmyExtension:NSObject
@end

@implementation AmyExtension

-(NSString*)identifier
{
	return @"";
}

@end

@implementation AmyWindowController

-(instancetype)initWithDocument:(AmyDocument*)document
{
	self=super.init;
	
	// TODO: a
	
	CGRect rect=CGRectMake(0,999999,600,600);
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	self.window.tabbingMode=NSWindowTabbingModePreferred;
	
	// TODO: what
	
	self.window.frameAutosaveName=@"amy";
	[self.window setFrameUsingName:@"amy"];
	
	self.xcodeViewController=[(XcodeViewController*)SoftViewController.alloc initWithNibName:nil bundle:nil document:document.xcodeDocument].autorelease;
	self.xcodeViewController.representedExtension=AmyExtension.alloc.init.autorelease;
	self.window.contentView=self.xcodeViewController.view;
	
	return self;
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	super.dealloc;
}

@end
