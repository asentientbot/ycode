enum
{
	TagSetting=1,
	TagTheme=2
};

@implementation Delegate

-(NSMenu*)addMenuTitle:(NSString*)title to:(NSMenu*)bar
{
	NSMenuItem* top=NSMenuItem.alloc.init.autorelease;
	NSMenu* menu=[NSMenu.alloc initWithTitle:title].autorelease;
	top.submenu=menu;
	[bar addItem:top];
	return menu;
}

-(NSMenuItem*)addItemTitle:(NSString*)title action:(NSString*)action key:(NSString*)key mask:(NSEventModifierFlags)mask to:(NSMenu*)menu
{
	NSMenuItem* item=[NSMenuItem.alloc initWithTitle:title action:NSSelectorFromString(action) keyEquivalent:key].autorelease;
	item.keyEquivalentModifierMask=mask;
	[menu addItem:item];
	return item;
}

-(NSMenuItem*)addItemTitle:(NSString*)title action:(NSString*)action key:(NSString*)key to:(NSMenu*)menu
{
	return [self addItemTitle:title action:action key:key mask:NSEventModifierFlagCommand to:menu];
}

-(void)addSeparatorTo:(NSMenu*)menu
{
	[menu addItem:NSMenuItem.separatorItem];
}

-(void)applicationWillFinishLaunching:(NSNotification*)note
{
	BOOL firstRun=![NSUserDefaults.standardUserDefaults boolForKey:@"launched"];
	[NSUserDefaults.standardUserDefaults setBool:true forKey:@"launched"];
	if(firstRun)
	{
		Settings.reset;
	}
	
	contextMenuHook=[^()
	{
		NSMenu* menu=NSMenu.alloc.init.autorelease;
		
		[self addItemTitle:@"Cut" action:@"cut:" key:@"" to:menu];
		[self addItemTitle:@"Copy" action:@"copy:" key:@"" to:menu];
		[self addItemTitle:@"Paste" action:@"paste:" key:@"" to:menu];
		
		return menu;
	} copy];
	
	NSMenu* bar=NSMenu.alloc.init.autorelease;
	
	NSMenu* titleMenu=[self addMenuTitle:getAppName() to:bar];
	[self addItemTitle:[@"About " stringByAppendingString:getAppName()] action:@"amyAbout:" key:@"" to:titleMenu];
	[self addSeparatorTo:titleMenu];
	for(NSString* name in Settings.allMappingNames)
	{
		[self addItemTitle:name action:@"amySettingsToggle:" key:@"" to:titleMenu].tag=TagSetting;
	}
	[self addSeparatorTo:titleMenu];
	[self addItemTitle:@"Reset Settings (May Need Reload)" action:@"amySettingsReset:" key:@"" to:titleMenu];
	[self addSeparatorTo:titleMenu];
	[self addItemTitle:@"Quit" action:@"terminate:" key:@"q" to:titleMenu];
	
	NSMenu* fileMenu=[self addMenuTitle:@"File" to:bar];
	[self addItemTitle:@"New Window" action:@"amyNewWindow:" key:@"n" to:fileMenu];
	[self addItemTitle:@"New Tab" action:@"amyNewTab:" key:@"n" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:fileMenu];
	[self addItemTitle:@"Open" action:@"openDocument:" key:@"o" to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemTitle:@"Close" action:@"performClose:" key:@"w" to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemTitle:@"Save" action:@"amySave:" key:@"s" to:fileMenu];
	
	NSMenu* editMenu=[self addMenuTitle:@"Edit" to:bar];
	[self addItemTitle:@"Undo" action:@"undo:" key:@"z" to:editMenu];
	[self addItemTitle:@"Redo" action:@"redo:" key:@"Z" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Cut" action:@"cut:" key:@"x" to:editMenu];
	[self addItemTitle:@"Copy" action:@"copy:" key:@"c" to:editMenu];
	[self addItemTitle:@"Paste" action:@"paste:" key:@"v" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Select All" action:@"selectAll:" key:@"a" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Shift Left" action:@"shiftLeft:" key:@"[" to:editMenu];
	[self addItemTitle:@"Shift Right" action:@"shiftRight:" key:@"]" to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Find" action:@"findAndReplace:" key:@"f" to:editMenu];
	[self addItemTitle:@"Find Next" action:@"findNext:" key:@"g" to:editMenu];
	[self addItemTitle:@"Find Previous" action:@"findPrevious:" key:@"G" to:editMenu];
	
	NSMenu* viewMenu=[self addMenuTitle:@"View" to:bar];
	for(NSString* name in Settings.allThemeNames)
	{
		[self addItemTitle:name action:@"amySetTheme:" key:@"" to:viewMenu].tag=TagTheme;
	}
	[self addSeparatorTo:viewMenu];
	[self addItemTitle:@"Enter Full Screen" action:@"toggleFullScreen:" key:@"f" mask:NSEventModifierFlagCommand|NSEventModifierFlagControl to:viewMenu];
	
	NSMenu* windowMenu=[self addMenuTitle:@"Window" to:bar];
	[self addItemTitle:@"Minimize" action:@"performMiniaturize:" key:@"m" to:windowMenu];
	[self addItemTitle:@"Zoom" action:@"performZoom:" key:@"" to:windowMenu];
	[self addSeparatorTo:windowMenu];
	[self addItemTitle:@"Show Previous Tab" action:@"selectPreviousTab:" key:@"←" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:windowMenu];
	[self addItemTitle:@"Show Next Tab" action:@"selectNextTab:" key:@"→" mask:NSEventModifierFlagCommand|NSEventModifierFlagOption to:windowMenu];
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
		[self addItemTitle:title action:@"amySelectTab:" key:key to:windowMenu];
	}
	
	NSApp.mainMenu=bar;
}

-(void)amyNewWindow:(NSMenuItem*)sender
{
	self.nextWindowIsNotTab=true;
	[NSDocumentController.sharedDocumentController newDocument:nil];
}

-(void)amyNewTab:(NSMenuItem*)sender
{
	[NSDocumentController.sharedDocumentController newDocument:nil];
}

-(BOOL)shouldMakeTab
{
	BOOL result=!self.nextWindowIsNotTab;
	self.nextWindowIsNotTab=false;
	return result;
}

-(void)amySelectTab:(NSMenuItem*)sender
{
	NSArray<NSWindow*>* windows=NSApp.keyWindow.tabbedWindows;
	int value=sender.keyEquivalent.intValue;
	if(value==9)
	{
		value=INT_MAX;
	}
	value=MIN(value,windows.count)-1;
	[windows[value] makeKeyAndOrderFront:nil];
}

-(void)amyAbout:(NSMenuItem*)sender
{
	NSString* gitInfo=[NSString stringWithUTF8String:stringify(gitHash)];
	if(gitInfo.length==0)
	{
		gitInfo=@"[unknown Git commit]";
	}
	
	alert([NSString stringWithFormat:@"Amy's meme text editor\n\n%@\n\ndo not actually use this",gitInfo]);
}

-(BOOL)validateUserInterfaceItem:(NSObject<NSValidatedUserInterfaceItem>*)item
{
	if([item isKindOfClass:NSMenuItem.class])
	{
		NSMenuItem* menuItem=(NSMenuItem*)item;
		
		switch(menuItem.tag)
		{
			case TagSetting:
				;
				SettingsMapping* mapping=[Settings mappingWithName:menuItem.title];
				if(mapping.supported)
				{
					menuItem.state=mapping.getValue?NSControlStateValueOn:NSControlStateValueOff;
				}
				else
				{
					return false;
				}
				break;
			case TagTheme:
				menuItem.state=[menuItem.title isEqual:Settings.currentThemeName]?NSControlStateValueOn:NSControlStateValueOff;
				break;
		}
	}
	
	return [self respondsToSelector:item.action];
}

-(void)amySettingsToggle:(NSMenuItem*)sender
{
	SettingsMapping* mapping=[Settings mappingWithName:sender.title];
	[mapping setValue:sender.state!=NSControlStateValueOn];
}

-(void)amySettingsReset:(NSMenuItem*)sender
{
	Settings.reset;
}

-(void)amySetTheme:(NSMenuItem*)sender
{
	[Settings setCurrentThemeName:sender.title];
}

@end
