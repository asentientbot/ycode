#define ScratchWidth 600
#define ScratchHeight 500

NSColor* (*hackRealColor)(NSObject*,SEL,NSString*,NSBundle*)=NULL;
NSColor* hackFakeColor(NSObject* self,SEL sel,NSString* name,NSBundle* bundle)
{
	if([name containsString:@"_NSTabBar"])
	{
		if([@[@"_NSTabBarTabFillColorSelectedActiveWindow"] containsObject:name])
		{
			return getXcodeTheme().sourceTextBackgroundColor;
		}
		
		if([@[@"_NSTabBarTabFillColorActiveWindow"] containsObject:name])
		{
			return getXcodeTheme().sourceTextCurrentLineHighlightColor;
		}
		
		if([@[@"_NSTabBarInactiveTabHoverColor",@"_NSTabBarNewTabButtonHoverColor",@"_NSTabBarSemitransparentDividerColor"] containsObject:name])
		{
			return getXcodeTheme().sourceTextSelectionColor;
		}
	}
	
	return hackRealColor(self,sel,name,bundle);
}

NSColor* hackFakeShadow()
{
	return NSColor.clearColor;
}

void (*hackRealHeaderLayout)(NSView*,SEL);
void hackFakeHeaderLayout(NSView* self,SEL sel)
{
	hackRealHeaderLayout(self,sel);
	
	self.subviews.firstObject.hidden=true;
	self.layer.backgroundColor=getXcodeTheme().sourceTextBackgroundColor.CGColor;
}

CGImageRef createThemeAppIcon()
{
	return createAppIcon(getXcodeTheme().sourceTextBackgroundColor.CGColor,getXcodeTheme().sourcePlainTextColor.CGColor,getXcodeTheme().sourceTextCurrentLineHighlightColor.CGColor);
}

@implementation WindowController

+(void)initialize
{
	if(@available(macOS 11,*))
	{
		swizzle(@"NSColor",@"colorNamed:bundle:",false,(IMP)hackFakeColor,(IMP*)&hackRealColor);
		swizzle(@"NSTitlebarSeparatorView",@"updateLayer",true,(IMP)returnNil,NULL);
	}
	
	// TODO: uhh
	
	if(NSClassFromString(@"_TtC12SourceEditor21StickyHeaderStackView"))
	{
		swizzle(@"_TtC12SourceEditor21StickyHeaderStackView",@"layout",true,(IMP)hackFakeHeaderLayout,(IMP*)&hackRealHeaderLayout);
	
		swizzle(@"NSColor",@"shadowWithLevel:",true,(IMP)hackFakeShadow,NULL);
		swizzle(@"NSColor",@"highlightWithLevel:",true,(IMP)hackFakeShadow,NULL);
	}
	
	[NSNotificationCenter.defaultCenter addObserverForName:XcodeThemeChangedKey object:nil queue:nil usingBlock:^(NSNotification* note)
	{
		[WindowController.allInstances makeObjectsPerformSelector:@selector(syncTheme)];
	}];
}

+(NSArray<WindowController*>*)allInstances
{
	NSMutableArray* result=NSMutableArray.alloc.init.autorelease;
	for(Document* document in NSDocumentController.sharedDocumentController.documents)
	{
		[result addObjectsFromArray:document.windowControllers];
	}
	return result;
}

+(WindowController*)firstInstance
{
	return WindowController.allInstances.firstObject;
}

+(WindowController*)lastInstance
{
	return WindowController.allInstances.lastObject;
}

+(void)syncProjectMode
{
	NSWindow* previousKeyWindow=NSApp.keyWindow;
	
	WindowController* previous=nil;
	for(WindowController* instance in WindowController.allInstances)
	{
		[instance syncProjectModeWithPrevious:previous];
		previous=instance;
	}
	
	if(Delegate.shared.projectMode)
	{
		// TODO: hack to preserve window ordering
		// it seems key window becomes tab 1; who calls mergeAllWindows: is irrelevant
		
		[WindowController.firstInstance.window makeKeyAndOrderFront:nil];
		[WindowController.firstInstance.window mergeAllWindows:nil];
	}
	
	[previousKeyWindow makeKeyAndOrderFront:nil];
}

-(instancetype)init
{
	self=super.init;
	
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:CGRectZero styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	self.window.titlebarAppearsTransparent=true;
	self.window.delegate=Delegate.shared;
	[self syncProjectModeWithPrevious:WindowController.lastInstance];
	
	self.syncTheme;
	
	return self;
}

-(void)replaceDocument:(Document*)document
{
	NSRange oldSelection=getXcodeViewControllerSelection(self.xcodeViewController);
	
	self.xcodeViewController=getXcodeViewController(document.xcodeDocument);
	self.window.contentView=self.xcodeViewController.view;
	
	focusXcodeViewController(self.xcodeViewController,oldSelection);
}

-(void)syncProjectModeWithPrevious:(WindowController*)previous
{
	if(Delegate.shared.projectMode)
	{
		self.window.tabbingMode=NSWindowTabbingModePreferred;
		[self.window setFrame:Settings.projectRect display:false];
		
		return;
	}
	
	self.window.tabbingMode=NSWindowTabbingModeDisallowed;
	[self.window moveTabToNewWindow:nil];
	
	CGRect previousRect=previous?previous.window.frame:NSScreen.mainScreen.visibleFrame;
	CGFloat toolbarHeight=[self.window frameRectForContentRect:CGRectZero].size.height;
	CGRect cascadedRect=CGRectMake(previousRect.origin.x+toolbarHeight,previousRect.origin.y+previousRect.size.height-ScratchHeight-toolbarHeight,ScratchWidth,ScratchHeight);
	[self.window setFrame:cascadedRect display:false];
	
	if(CGRectEqualToRect(Settings.projectRect,CGRectZero))
	{
		Settings.projectRect=cascadedRect;
	}
}

-(void)syncTheme
{
	dispatch_async(dispatch_get_main_queue(),^()
	{
		NSAppearance* appearance=[NSAppearance appearanceNamed:getXcodeTheme().hasLightBackground?NSAppearanceNameAqua:NSAppearanceNameVibrantDark];
		if(@available(macOS 10.14,*))
		{
			NSApp.appearance=appearance;
		}
		else
		{
			self.window.appearance=appearance;
		}
		
		self.window.backgroundColor=getXcodeTheme().sourceTextBackgroundColor;
		
		// TODO: hack to refresh the "new tab" button
		
		if(self.window.isKeyWindow)
		{
			self.window.resignKeyWindow;
			self.window.becomeKeyWindow;
		}
		
		CGImageRef icon=createThemeAppIcon();
		NSApp.applicationIconImage=[NSImage.alloc initWithCGImage:icon size:CGSizeZero].autorelease;
		CFRelease(icon);
	});
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	super.dealloc;
}

@end
