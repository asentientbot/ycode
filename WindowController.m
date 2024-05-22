@implementation WindowController

-(instancetype)initWithDocument:(Document*)document
{
	self=super.init;
	
	CGRect rect=CGRectMake(0,0,600,500);
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	
	// TODO: this now behaves exactly how i want, but it's very nonstandard
	
	Delegate* delegate=(Delegate*)NSApp.delegate;
	if(delegate.shouldMakeTab)
	{
		[self.window cascadeTopLeftFromPoint:CGPointMake(INT_MAX,INT_MAX)];
		
		self.window.tabbingMode=NSWindowTabbingModePreferred;
		self.window.frameAutosaveName=getAppName();
	}
	else
	{
		delegate.lastCascadePoint=[self.window cascadeTopLeftFromPoint:delegate.lastCascadePoint];
	}
	
	self.xcodeViewController=getXcodeViewController(document.xcodeDocument);
	self.window.contentView=self.xcodeViewController.view;
	focusXcodeViewController(self.xcodeViewController);
	
	return self;
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	super.dealloc;
}

@end
