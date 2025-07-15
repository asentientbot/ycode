enum
{
	TagSetting=1,
	TagTheme,
	TagProjectMode,
	TagTab,
	TagFileAssociation,
	TagReopen
};

@implementation Delegate

+(Delegate*)shared
{
	return (Delegate*)NSApp.delegate;
}

-(NSMenu*)addMenuWithTitle:(NSString*)title to:(NSMenu*)bar
{
	NSMenuItem* top=NSMenuItem.alloc.init.autorelease;
	NSMenu* menu=[NSMenu.alloc initWithTitle:title].autorelease;
	top.submenu=menu;
	[bar addItem:top];
	return menu;
}

-(NSMenuItem*)addItemWithTitle:(NSString*)title action:(NSString*)action key:(NSString*)key mask:(NSEventModifierFlags)mask to:(NSMenu*)menu
{
	NSMenuItem* item=[NSMenuItem.alloc initWithTitle:title action:NSSelectorFromString(action) keyEquivalent:key?key:@""].autorelease;
	item.keyEquivalentModifierMask=mask;
	[menu addItem:item];
	return item;
}

-(NSMenuItem*)addItemWithTitle:(NSString*)title action:(NSString*)action key:(NSString*)key to:(NSMenu*)menu
{
	return [self addItemWithTitle:title action:action key:key mask:NSEventModifierFlagCommand to:menu];
}

-(void)addSeparatorTo:(NSMenu*)menu
{
	[menu addItem:NSMenuItem.separatorItem];
}

-(void)applicationWillFinishLaunching:(NSNotification*)note
{
	BOOL firstRun=![NSUserDefaults.standardUserDefaults boolForKey:@"launched"];
	if(firstRun)
	{
		[NSUserDefaults.standardUserDefaults setBool:true forKey:@"launched"];
		Settings.reset;
	}
	
	contextMenuHook=[^()
	{
		NSMenu* menu=NSMenu.alloc.init.autorelease;
		
		[self addItemWithTitle:@"Cut" action:@"cut:" key:nil to:menu];
		[self addItemWithTitle:@"Copy" action:@"copy:" key:nil to:menu];
		[self addItemWithTitle:@"Paste" action:@"paste:" key:nil to:menu];
		
		return menu;
	} copy];
	
	NSMenu* bar=NSMenu.alloc.init.autorelease;
	
	NSMenu* titleMenu=[self addMenuWithTitle:getAppName() to:bar];
	[self addItemWithTitle:[@"About " stringByAppendingString:getAppName()] action:@"handleAbout:" key:nil to:titleMenu];
	[self addSeparatorTo:titleMenu];
	for(NSString* name in Settings.allMappingNames)
	{
		[self addItemWithTitle:name action:@"handleSettingsToggle:" key:nil to:titleMenu].tag=TagSetting;
	}
	[self addSeparatorTo:titleMenu];
	[self addItemWithTitle:@"Reset Settings (May Need Reload)" action:@"handleSettingsReset:" key:nil to:titleMenu];
	[self addSeparatorTo:titleMenu];
	[self addItemWithTitle:[@"Hide " stringByAppendingString:getAppName()] action:@"hide:" key:@"h" to:titleMenu];
	[self addItemWithTitle:@"Hide Others" action:@"hideOtherApplications:" key:@"h" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:titleMenu];
	[self addItemWithTitle:@"Show All" action:@"unhideAllApplications:" key:nil to:titleMenu];
	[self addSeparatorTo:titleMenu];
	[self addItemWithTitle:[@"Quit " stringByAppendingString:getAppName()] action:@"terminate:" key:@"q" to:titleMenu];
	
	NSMenu* fileMenu=[self addMenuWithTitle:@"File" to:bar];
	[self addItemWithTitle:@"New" action:@"newDocument:" key:@"n" to:fileMenu];
	[self addItemWithTitle:@"Open" action:@"openDocument:" key:@"o" to:fileMenu];
	[self addItemWithTitle:@"" action:@"handleReopen:" key:@"T" to:fileMenu].tag=TagReopen;
	[self addSeparatorTo:fileMenu];
	[self addItemWithTitle:@"Close" action:@"performClose:" key:@"w" to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemWithTitle:@"Save" action:@"handleSave:" key:@"s" to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemWithTitle:@"" action:@"handleClaimFileAssociation:" key:nil to:fileMenu].tag=TagFileAssociation;
	
	NSMenu* editMenu=[self addMenuWithTitle:@"Edit" to:bar];
	[self addItemWithTitle:@"Undo" action:@"undo:" key:@"z" to:editMenu];
	[self addItemWithTitle:@"Redo" action:@"redo:" key:@"Z" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemWithTitle:@"Cut" action:@"cut:" key:@"x" to:editMenu];
	[self addItemWithTitle:@"Copy" action:@"copy:" key:@"c" to:editMenu];
	[self addItemWithTitle:@"Paste" action:@"paste:" key:@"v" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemWithTitle:@"Select All" action:@"selectAll:" key:@"a" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemWithTitle:@"Shift Left" action:@"shiftLeft:" key:@"[" to:editMenu];
	[self addItemWithTitle:@"Shift Right" action:@"shiftRight:" key:@"]" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemWithTitle:@"Find" action:@"findAndReplace:" key:@"f" to:editMenu];
	[self addItemWithTitle:@"Find Next" action:@"findNext:" key:@"g" to:editMenu];
	[self addItemWithTitle:@"Find Previous" action:@"findPrevious:" key:@"G" to:editMenu];
	
	NSMenu* viewMenu=[self addMenuWithTitle:@"View" to:bar];
	for(NSString* name in Settings.allThemeNames)
	{
		[self addItemWithTitle:name action:@"handleSetTheme:" key:nil to:viewMenu].tag=TagTheme;
	}
	[self addSeparatorTo:viewMenu];
	[self addItemWithTitle:@"Enter Full Screen" action:@"toggleFullScreen:" key:@"f" mask:NSEventModifierFlagCommand|NSEventModifierFlagControl to:viewMenu];
	
	NSMenu* windowMenu=[self addMenuWithTitle:@"Window" to:bar];
	[self addItemWithTitle:@"Project Mode" action:@"handleToggleProjectMode:" key:@"p" to:windowMenu].tag=TagProjectMode;
	[self addSeparatorTo:windowMenu];
	[self addItemWithTitle:@"Minimize" action:@"performMiniaturize:" key:@"m" to:windowMenu];
	[self addItemWithTitle:@"Zoom" action:@"performZoom:" key:nil to:windowMenu];
	[self addSeparatorTo:windowMenu];
	[self addItemWithTitle:@"Show Previous Tab" action:@"selectPreviousTab:" key:@"←" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:windowMenu];
	[self addItemWithTitle:@"Show Next Tab" action:@"selectNextTab:" key:@"→" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:windowMenu];
	[self addSeparatorTo:windowMenu];
	for(int index=1;index<10;index++)
	{
		NSString* title=nil;
		if(index==9)
		{
			title=@"Show Last Tab";
		}
		else
		{
			title=[NSString stringWithFormat:@"Show Tab %d",index];
		}
		NSString* key=[NSString stringWithFormat:@"%d",index];
		[self addItemWithTitle:title action:@"handleSelectTab:" key:key to:windowMenu].tag=TagTab;
	}
	
	NSApp.mainMenu=bar;
	
	self.currentScreenKey=Settings.screenKey;
}

-(BOOL)validateUserInterfaceItem:(NSObject<NSValidatedUserInterfaceItem>*)item
{
	if([item isKindOfClass:NSMenuItem.class])
	{
		NSMenuItem* menuItem=(NSMenuItem*)item;
		BOOL checked=false;
		BOOL disabled=false;
		
		switch(menuItem.tag)
		{
			case TagSetting:
				;
				SettingsMapping* mapping=[Settings mappingWithName:menuItem.title];
				disabled=!mapping.supported;
				checked=mapping.getValue;
				break;
			case TagTheme:
				checked=[menuItem.title isEqual:Settings.currentThemeName];
				break;
			case TagProjectMode:
				checked=self.projectMode;
				break;
			case TagTab:
				disabled=!self.projectMode;
				break;
			case TagFileAssociation:
				;
				Document* document=NSApp.keyWindow.windowController.document;
				if(document)
				{
					menuItem.title=[NSString stringWithFormat:@"Claim File Type \"%@\"",document.xcodeDocument.fileType];
					NSString* existing=((NSString*)LSCopyDefaultRoleHandlerForContentType((CFStringRef)document.xcodeDocument.fileType,kLSRolesAll)).autorelease;
					if([existing isEqual:NSBundle.mainBundle.bundleIdentifier])
					{
						disabled=true;
					}
				}
				else
				{
					menuItem.title=@"Claim File Type";
					disabled=true;
				}
				break;
			case TagReopen:
				;
				NSURL* url=self.urlToReopen;
				if(url)
				{
					menuItem.title=[NSString stringWithFormat:@"Reopen \"%@\"",url.lastPathComponent];
				}
				else
				{
					menuItem.title=@"Reopen Last Closed";
					disabled=true;
				}
				break;
		}
		
		menuItem.state=checked?NSControlStateValueOn:NSControlStateValueOff;
		if(disabled)
		{
			return false;
		}
	}
	
	return true;
}

-(void)handleSelectTab:(NSMenuItem*)sender
{
	int value=sender.keyEquivalent.intValue;
	if(value==9)
	{
		value=INT_MAX;
	}

	NSArray<NSWindow*>* windows=NSApp.keyWindow.tabbedWindows;
	[windows[MIN(value,windows.count)-1] makeKeyAndOrderFront:nil];
}

-(NSURL*)urlToReopen
{
	for(NSURL* url in NSDocumentController.sharedDocumentController.recentDocumentURLs)
	{
		if(![NSDocumentController.sharedDocumentController documentForURL:url])
		{
			return url;
		}
	}
	
	return nil;
}

-(void)handleReopen:(NSMenuItem*)sender
{
	[NSDocumentController.sharedDocumentController openDocumentWithContentsOfURL:self.urlToReopen display:true completionHandler:^(NSDocument* document,BOOL wasAlreadyOpen,NSError* error)
	{
	}];
}

-(void)handleAbout:(NSMenuItem*)sender
{
	NSString* gitInfo=[NSString stringWithUTF8String:stringify(gitHash)];
	if(gitInfo.length==0)
	{
		gitInfo=@"[unknown commit]";
	}
	
	alert([NSString stringWithFormat:@"Amy's meme text editor\n\n%@",gitInfo]);
}

-(void)handleSettingsToggle:(NSMenuItem*)sender
{
	[Settings mappingWithName:sender.title].toggle;
}

-(void)handleSettingsReset:(NSMenuItem*)sender
{
	Settings.reset;
}

-(void)handleSetTheme:(NSMenuItem*)sender
{
	[Settings setCurrentThemeName:sender.title];
}

-(void)handleToggleProjectMode:(NSMenuItem*)sender
{
	self.projectMode=!self.projectMode;
	WindowController.syncProjectMode;
}

-(void)handleClaimFileAssociation:(NSMenuItem*)sender
{
	Document* document=NSApp.keyWindow.windowController.document;
	LSSetDefaultRoleHandlerForContentType((CFStringRef)document.xcodeDocument.fileType,kLSRolesAll,(CFStringRef)NSBundle.mainBundle.bundleIdentifier);
}

-(void)handleFrameChange:(NSWindow*)window
{
	if(!self.projectMode)
	{
		return;
	}
	
	if(![self.currentScreenKey isEqual:Settings.screenKey])
	{
		return;
	}
	
	Settings.projectRect=window.frame;
}

-(void)windowDidResize:(NSNotification*)note
{
	[self handleFrameChange:(NSWindow*)note.object];
}

-(void)windowDidMove:(NSNotification*)note
{
	[self handleFrameChange:(NSWindow*)note.object];
}

-(void)applicationDidChangeScreenParameters:(NSNotification*)note
{
	WindowController.syncProjectMode;
	self.currentScreenKey=Settings.screenKey;
}

-(void)dealloc
{
	self.currentScreenKey=nil;
	
	super.dealloc;
}

@end
