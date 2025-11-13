@implementation WindowController

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
		Delegate.shared.ignoreFrameChanges=true;
		
		NSWindow* previousKeyWindow=NSApp.keyWindow;
		
		WindowController* previous=nil;
		for(WindowController* instance in WindowController.allInstances)
		{
			[instance syncProjectModeWithPrevious:previous];
			previous=instance;
		}
		
		if(Delegate.shared.projectMode)
		{
			[previousKeyWindow mergeAllWindows:nil];
		}
		
		[previousKeyWindow makeKeyAndOrderFront:nil];
		
		if(Delegate.shared.projectMode&&!Settings.showedProjectModeExplanation)
		{
			Settings.showedProjectModeExplanation=true;
			
			alert(@"Project Mode uses tabs and remembers the window dimensions across launches (like TextMate). Switch back to the default mode for little windows (like TextEdit).");
		}
		
		Delegate.shared.ignoreFrameChanges=false;
	});
}

+(void)syncTheme
{
	dispatch_async(dispatch_get_main_queue(),^()
	{
		[WindowController.allInstances makeObjectsPerformSelector:@selector(syncTheme)];
	});
}

-(instancetype)init
{
	self=super.init;
	
	NSWindowStyleMask style=NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable;
	self.window=[NSWindow.alloc initWithContentRect:CGRectZero styleMask:style backing:NSBackingStoreBuffered defer:false].autorelease;
	self.window.delegate=Delegate.shared;
	
	// TODO: a tahoe bug or i was relying on undefined behavior? idk
	
	self.window.backgroundColor=[Settings colorWithString:AmyThemeBackgroundColor];
	
	[self syncProjectModeWithPrevious:WindowController.lastInstance];
	
	self.syncTheme;
	
	return self;
}

-(void)setXcodeViewController:(XcodeViewController*)newController
{
	NSRange oldSelection=[Xcode selectionWithViewController:_xcodeViewController];
	
	if(_xcodeViewController)
	{
		[Xcode destroyViewController:_xcodeViewController];
		
		_xcodeViewController.release;
	}
	
	_xcodeViewController=newController.retain;
	
	if(_xcodeViewController)
	{
		self.window.contentView=_xcodeViewController.view;
		
		[Xcode focusViewController:_xcodeViewController withSelection:oldSelection];
	}
}

-(void)replaceDocument:(Document*)document
{
	self.xcodeViewController=[Xcode viewControllerWithDocument:document.xcodeDocument];
}

-(void)syncProjectModeWithPrevious:(WindowController*)previous
{
	if(!Delegate.shared.projectMode)
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
		self.window.tabbingMode=NSWindowTabbingModePreferred;
		[self.window setFrame:Settings.projectRect display:false];
	}
	else
	{
		[self.window setFrame:cascadedRect display:false];
	}
}

-(void)syncTheme
{
	NSAppearance* appearance=[NSAppearance appearanceNamed:Xcode.themeIsLight?NSAppearanceNameAqua:NSAppearanceNameVibrantDark];
	if(@available(macOS 10.14,*))
	{
		NSApp.appearance=appearance;
	}
	else
	{
		self.window.appearance=appearance;
	}
}

-(void)dealloc
{
	self.xcodeViewController=nil;
	
	super.dealloc;
}

@end
