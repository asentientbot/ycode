@implementation WindowController

-(instancetype)initWithDocument:(Document*)document
{
	self=super.init;
	
	// TODO: a
	
	CGRect rect=CGRectMake(0,999999,600,600);
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	self.window.tabbingMode=NSWindowTabbingModePreferred;
	
	// TODO: what
	
	self.window.frameAutosaveName=getAppName();
	[self.window setFrameUsingName:getAppName()];
	
	self.xcodeViewController=getXcodeViewController(document.xcodeDocument);
	self.window.contentView=self.xcodeViewController.view;
	
	return self;
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	super.dealloc;
}

@end
