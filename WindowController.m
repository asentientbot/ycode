#define ScratchWidth 600
#define ScratchHeight 500

dispatch_once_t windowControllerInitializeOnce;

@implementation WindowController

+(void)initialize
{
	dispatch_once(&windowControllerInitializeOnce,^()
	{
		[NSNotificationCenter.defaultCenter addObserverForName:XcodeThemeChangedKey object:nil queue:nil usingBlock:^(NSNotification* note)
		{
			[WindowController.allInstances makeObjectsPerformSelector:@selector(syncTheme)];
		}];
	});
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
	dispatch_async(dispatch_get_main_queue(),^()
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
			[WindowController.firstInstance.window mergeAllWindows:nil];
		}
		
		[previousKeyWindow makeKeyAndOrderFront:nil];
	});
}

-(instancetype)init
{
	self=super.init;
	
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:CGRectZero styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	self.window.delegate=Delegate.shared;
	[self syncProjectModeWithPrevious:WindowController.lastInstance];
	
	self.syncTheme;
	
	return self;
}

-(void)replaceDocument:(Document*)document
{
	NSRange oldSelection=getXcodeViewControllerSelection(self.xcodeViewController);
	
	// TODO: this and the similar copy+pasted dealloc code in Document.m should be moved somewhere else, probably Xcode.m or custom property setter
	
	self.window.contentView=nil;
	self.xcodeViewController.invalidate;
	self.xcodeViewController=getXcodeViewController(document.xcodeDocument);
	self.window.contentView=self.xcodeViewController.view;
	
	// TODO: hack to load content immediately
	
	self.window.display;
	
	focusXcodeViewController(self.xcodeViewController,oldSelection);
}

-(void)syncProjectModeWithPrevious:(WindowController*)previous
{
	if(Delegate.shared.projectMode)
	{
		self.window.tabbingMode=NSWindowTabbingModePreferred;
	}
	else
	{
		self.window.tabbingMode=NSWindowTabbingModeDisallowed;
		[self.window moveTabToNewWindow:nil];
	}
	
	// TODO: i feel like some of this should be in Settings, but we don't have access to previous window and toolbar height there..
	
	CGRect previousRect=previous?previous.window.frame:NSScreen.mainScreen.visibleFrame;
	CGFloat toolbarHeight=[self.window frameRectForContentRect:CGRectZero].size.height;
	CGRect cascadedRect=CGRectMake(previousRect.origin.x+toolbarHeight,previousRect.origin.y+previousRect.size.height-ScratchHeight-toolbarHeight,ScratchWidth,ScratchHeight);
	
	if(CGRectEqualToRect(Settings.projectRect,CGRectZero))
	{
		Settings.projectRect=cascadedRect;
	}
	
	if(Delegate.shared.projectMode)
	{
		[self.window setFrame:Settings.projectRect display:false];
	}
	else
	{
		[self.window setFrame:cascadedRect display:false];
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
	});
}

-(void)dealloc
{
	// TODO: idk exactly what this does, but it fixes the memory leak. empirically, XcodeViewController.invalidate and XcodeDocument.close are both needed in addition to releasing normally
	
	self.window.contentView=nil;
	self.xcodeViewController.invalidate;
	
	self.xcodeViewController=nil;
	
	super.dealloc;
}

@end
