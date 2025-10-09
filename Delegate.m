@implementation Delegate

+(Delegate*)shared
{
	return (Delegate*)NSApp.delegate;
}

-(void)setProjectMode:(BOOL)value
{
	_projectMode=value;
	
	WindowController.syncProjectMode;
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
	Settings.checkFirstRun;
	
	NSMenu* bar=NSMenu.alloc.init.autorelease;
	
	NSMenu* nameMenu=[self addMenuWithTitle:AppName to:bar];
	
	[self addItemWithTitle:[@"About " stringByAppendingString:AppName] action:@"handleAbout:" key:nil to:nameMenu];
	[self addSeparatorTo:nameMenu];
	
	for(NSString* name in Settings.mappingNames)
	{
		[self addItemWithTitle:name action:@"handleSettingsToggle:" key:nil to:nameMenu].tag=TagSetting;
	}
	[self addSeparatorTo:nameMenu];
	
	[self addItemWithTitle:@"Reset Settings (May Need Reload)" action:@"handleSettingsReset:" key:nil to:nameMenu];
	[self addSeparatorTo:nameMenu];
	
	[self addItemWithTitle:[@"Hide " stringByAppendingString:AppName] action:@"hide:" key:@"h" to:nameMenu];
	[self addItemWithTitle:@"Hide Others" action:@"hideOtherApplications:" key:@"h" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:nameMenu];
	[self addItemWithTitle:@"Show All" action:@"unhideAllApplications:" key:nil to:nameMenu];
	[self addSeparatorTo:nameMenu];
	
	[self addItemWithTitle:[@"Quit " stringByAppendingString:AppName] action:@"terminate:" key:@"q" to:nameMenu];
	
	NSMenu* fileMenu=[self addMenuWithTitle:@"File" to:bar];
	
	[self addItemWithTitle:@"New" action:@"newDocument:" key:@"n" to:fileMenu];
	[self addItemWithTitle:@"Open" action:@"openDocument:" key:@"o" to:fileMenu];
	[self addItemWithTitle:@"Reopen Last Closed" action:@"handleReopen:" key:@"T" to:fileMenu];
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
	
	for(NSString* name in Xcode.themeNames)
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
	
	Xcode.contextMenuHook=^()
	{
		NSMenu* menu=NSMenu.alloc.init.autorelease;
		
		[self addItemWithTitle:@"Cut" action:@"cut:" key:nil to:menu];
		[self addItemWithTitle:@"Copy" action:@"copy:" key:nil to:menu];
		[self addItemWithTitle:@"Paste" action:@"paste:" key:nil to:menu];
		
		return menu;
	};
	
	[Xcode addThemeChangeHandler:^()
	{
		WindowController.syncTheme;
	}];
}

-(BOOL)validateUserInterfaceItem:(NSObject<NSValidatedUserInterfaceItem>*)item
{
	BOOL enabled=true;
	
	if([item isKindOfClass:NSMenuItem.class])
	{
		NSMenuItem* menuItem=(NSMenuItem*)item;
		BOOL checked=false;
		
		switch(menuItem.tag)
		{
			case TagSetting:
			{
				SettingsMapping* mapping=[Settings mappingWithName:menuItem.title];
				enabled=mapping.supported;
				checked=mapping.value;
				break;
			}
			case TagTheme:
				checked=[menuItem.title isEqual:Xcode.themeName];
				break;
			case TagProjectMode:
				checked=self.projectMode;
				break;
			case TagTab:
				enabled=self.projectMode;
				break;
			case TagFileAssociation:
			{
				Document* document=NSApp.keyWindow.windowController.document;
				if(document)
				{
					menuItem.title=[NSString stringWithFormat:@"Claim File Type \"%@\"",document.actualFileType];
					NSString* existing=((NSString*)LSCopyDefaultRoleHandlerForContentType((CFStringRef)document.xcodeDocument.fileType,kLSRolesAll)).autorelease;
					if([existing isEqual:NSBundle.mainBundle.bundleIdentifier])
					{
						enabled=false;
					}
				}
				else
				{
					menuItem.title=@"Claim File Type";
					enabled=false;
				}
				break;
			}
		}
		
		menuItem.state=checked?NSControlStateValueOn:NSControlStateValueOff;
	}
	
	return enabled;
}

-(void)handleAbout:(NSMenuItem*)sender
{
	alert([NSString stringWithFormat:@"amy's meme text editor\n\n%@",GitHash]);
}

-(void)handleSettingsToggle:(NSMenuItem*)sender
{
	[Settings mappingWithName:sender.title].toggle;
}

-(void)handleSettingsReset:(NSMenuItem*)sender
{
	Settings.reset;
}

-(void)handleReopen:(NSMenuItem*)sender
{
	LSSharedFileListRef opaqueList=LSSharedFileListCreate(NULL,CFSTR("com.apple.LSSharedFileList.ApplicationRecentDocuments"),NULL);
	NSArray* actualList=((NSArray*)LSSharedFileListCopySnapshot(opaqueList,NULL)).autorelease;
	CFRelease(opaqueList);
	
	for(id item in actualList)
	{
		NSURL* url=((NSURL*)LSSharedFileListItemCopyResolvedURL((LSSharedFileListItemRef)item,0,NULL)).autorelease;
		if(!url)
		{
			continue;
		}
		
		if([NSDocumentController.sharedDocumentController documentForURL:url])
		{
			continue;
		}
		
		[NSDocumentController.sharedDocumentController openDocumentWithContentsOfURL:url display:true completionHandler:^(NSDocument* document,BOOL wasAlreadyOpen,NSError* error)
		{
		}];
		
		break;
	}
}

-(void)handleClaimFileAssociation:(NSMenuItem*)sender
{
	Document* document=NSApp.keyWindow.windowController.document;
	LSSetDefaultRoleHandlerForContentType((CFStringRef)document.actualFileType,kLSRolesAll,(CFStringRef)NSBundle.mainBundle.bundleIdentifier);
}

-(void)handleSetTheme:(NSMenuItem*)sender
{
	Xcode.themeName=sender.title;
}

-(void)handleToggleProjectMode:(NSMenuItem*)sender
{
	self.projectMode=!self.projectMode;
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

-(void)handleFrameChange:(CGRect)frame
{
	if(self.ignoreFrameChanges||!self.projectMode)
	{
		return;
	}
	
	if(![self.currentScreenKey isEqual:Settings.screenKey])
	{
		return;
	}
	
	Settings.projectRect=frame;
}

-(void)windowDidResize:(NSNotification*)note
{
	[self handleFrameChange:((NSWindow*)note.object).frame];
}

-(void)windowDidMove:(NSNotification*)note
{
	[self handleFrameChange:((NSWindow*)note.object).frame];
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
