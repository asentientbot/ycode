@implementation WindowController

-(instancetype)initWithDocument:(Document*)document
{
	self=super.init;
	
	CGRect screen=NSScreen.mainScreen.frame;
	int width=600;
	int height=500;
	CGRect rect=CGRectMake((screen.size.width-width)/2,(screen.size.height-height)/2,width,height);
	
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	
	// TODO: this now behaves exactly how i want, but it's very nonstandard
	
	Delegate* delegate=(Delegate*)NSApp.delegate;
	if(delegate.shouldMakeTab)
	{
		self.window.tabbingMode=NSWindowTabbingModePreferred;
		self.window.frameAutosaveName=getAppName();
	}
	else
	{
		CGPoint origin=rect.origin;
		if(!CGPointEqualToPoint(delegate.lastCascadePoint,CGPointZero))
		{
			origin=delegate.lastCascadePoint;
		}
		delegate.lastCascadePoint=[self.window cascadeTopLeftFromPoint:origin];
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
