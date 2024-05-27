NSColor* (*hackRealColor)(NSObject*,SEL,NSString*,NSBundle*)=NULL;
NSColor* hackFakeColor(NSObject* self,SEL sel,NSString* name,NSBundle* bundle)
{
	if([name containsString:@"_NSTabBar"])
	{
		NSColor* base=getXcodeThemeManager().currentPreferenceSet.sourceTextCurrentLineHighlightColor;
		
		if([@[@"_NSTabBarInactiveTabHoverColor",@"_NSTabBarNewTabButtonHoverColor"] containsObject:name])
		{
			return base;
		}
		
		if([@[@"_NSTabBarTabFillColorActiveWindow",@"_NSTabBarInactiveTabHoverColor",@"_NSTabBarNewTabButtonHoverColor"] containsObject:name])
		{
			// TODO: completely arbitrary
			
			return [base colorWithAlphaComponent:0.5];
		}
		
		return NSColor.clearColor;
	}
	
	return hackRealColor(self,sel,name,bundle);
}

@implementation WindowController

+(void)initialize
{
	swizzle(@"NSColor",@"colorNamed:bundle:",false,(IMP)hackFakeColor,(IMP*)&hackRealColor);
	
	[NSNotificationCenter.defaultCenter addObserverForName:XcodeThemeChangedKey object:nil queue:nil usingBlock:^(NSNotification* note)
	{
		for(Document* document in NSDocumentController.sharedDocumentController.documents)
		{
			for(WindowController* controller in document.windowControllers)
			{
				controller.syncTheme;
			}
		}
	}];
}

-(instancetype)initWithDocument:(Document*)document
{
	self=super.init;
	
	CGRect rect=CGRectMake(0,0,600,500);
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	[self.window cascadeTopLeftFromPoint:CGPointMake(INT_MAX,INT_MAX)];
	self.window.tabbingMode=NSWindowTabbingModePreferred;
	self.window.frameAutosaveName=getAppName();
	self.window.titlebarAppearsTransparent=true;
	
	self.xcodeViewController=getXcodeViewController(document.xcodeDocument);
	self.window.contentView=self.xcodeViewController.view;
	self.window.contentView.clipsToBounds=true;
	focusXcodeViewController(self.xcodeViewController);
	
	self.syncTheme;
	
	// TODO: make toggle-able? dependent on minimap?
	
	self.xcodeViewController.mainScrollView.hasVerticalScroller=false;
	
	return self;
}

-(void)syncTheme
{
	dispatch_async(dispatch_get_main_queue(),^()
	{
		XcodeTheme2* theme=getXcodeThemeManager().currentPreferenceSet;
		
		NSAppearance* appearance=[NSAppearance appearanceNamed:theme.hasLightBackground?NSAppearanceNameAqua:NSAppearanceNameVibrantDark];
		if(@available(macOS 10.14,*))
		{
			NSApp.appearance=appearance;
		}
		else
		{
			self.window.appearance=appearance;
		}
		
		self.window.backgroundColor=theme.sourceTextBackgroundColor;
		
		// TODO: hack to refresh the "new tab" button
		
		if(self.window.isKeyWindow)
		{
			self.window.resignKeyWindow;
			self.window.becomeKeyWindow;
		}
	});
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	super.dealloc;
}

@end
