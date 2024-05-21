@implementation Delegate

-(NSMenu*)addMenuTitle:(NSString*)title to:(NSMenu*)bar
{
	NSMenuItem* top=NSMenuItem.alloc.init.autorelease;
	NSMenu* menu=[NSMenu.alloc initWithTitle:title].autorelease;
	top.submenu=menu;
	[bar addItem:top];
	return menu;
}

-(void)addItemTitle:(NSString*)title action:(NSString*)action key:(NSString*)key mask:(NSEventModifierFlags)mask to:(NSMenu*)menu
{
	NSMenuItem* item=[NSMenuItem.alloc initWithTitle:title action:NSSelectorFromString(action) keyEquivalent:key].autorelease;
	item.keyEquivalentModifierMask=NSEventModifierFlagCommand|mask;
	[menu addItem:item];
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
	
	NSMenu* bar=NSMenu.alloc.init.autorelease;
	
	NSMenu* titleMenu=[self addMenuTitle:getAppName() to:bar];
	[self addItemTitle:[@"About " stringByAppendingString:getAppName()] action:@"amyAbout:" key:@"" mask:0 to:titleMenu];
	[self addSeparatorTo:titleMenu];
	for(NSString* name in Settings.allNames)
	{
		[self addItemTitle:name action:@"amySettingsToggle:" key:@"" mask:0 to:titleMenu];
	}
	[self addSeparatorTo:titleMenu];
	[self addItemTitle:@"Reset Settings (Needs Reload)" action:@"amySettingsReset:" key:@"" mask:0 to:titleMenu];
	[self addSeparatorTo:titleMenu];
	[self addItemTitle:@"Quit" action:@"terminate:" key:@"q" mask:0 to:titleMenu];
	
	NSMenu* fileMenu=[self addMenuTitle:@"File" to:bar];
	[self addItemTitle:@"New" action:@"newDocument:" key:@"n" mask:0 to:fileMenu];
	[self addItemTitle:@"Open" action:@"openDocument:" key:@"o" mask:0 to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemTitle:@"Close" action:@"performClose:" key:@"w" mask:0 to:fileMenu];
	[self addSeparatorTo:fileMenu];
	[self addItemTitle:@"Save" action:@"amySave:" key:@"s" mask:0 to:fileMenu];
	
	NSMenu* editMenu=[self addMenuTitle:@"Edit" to:bar];
	[self addItemTitle:@"Undo" action:@"undo:" key:@"z" mask:0 to:editMenu];
	[self addItemTitle:@"Redo" action:@"redo:" key:@"Z" mask:0 to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Cut" action:@"cut:" key:@"x" mask:0 to:editMenu];
	[self addItemTitle:@"Copy" action:@"copy:" key:@"c" mask:0 to:editMenu];
	[self addItemTitle:@"Paste" action:@"paste:" key:@"v" mask:0 to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Select All" action:@"selectAll:" key:@"a" mask:0 to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Shift Left" action:@"shiftLeft:" key:@"[" mask:0 to:editMenu];
	[self addItemTitle:@"Shift Right" action:@"shiftRight:" key:@"]" mask:0 to:editMenu];
	[self addSeparatorTo:editMenu];
	[self addItemTitle:@"Find" action:@"findAndReplace:" key:@"f" mask:0 to:editMenu];
	[self addItemTitle:@"Find Next" action:@"findNext:" key:@"g" mask:0 to:editMenu];
	[self addItemTitle:@"Find Previous" action:@"findPrevious:" key:@"G" mask:0 to:editMenu];
	
	NSMenu* viewMenu=[self addMenuTitle:@"View" to:bar];
	[self addItemTitle:@"Enter Full Screen" action:@"toggleFullScreen:" key:@"f" mask:NSEventModifierFlagControl to:viewMenu];
	
	NSMenu* windowMenu=[self addMenuTitle:@"Window" to:bar];
	[self addItemTitle:@"Minimize" action:@"performMiniaturize:" key:@"m" mask:0 to:windowMenu];
	[self addItemTitle:@"Zoom" action:@"performZoom:" key:@"" mask:0 to:windowMenu];
	[self addSeparatorTo:windowMenu];
	[self addItemTitle:@"Show Previous Tab" action:@"selectPreviousTab:" key:@"←" mask:NSEventModifierFlagOption to:windowMenu];
	[self addItemTitle:@"Show Next Tab" action:@"selectNextTab:" key:@"→" mask:NSEventModifierFlagOption to:windowMenu];
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
		[self addItemTitle:title action:@"amySelectTab:" key:key mask:0 to:windowMenu];
	}
	
	NSApp.mainMenu=bar;
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
	alert([NSString stringWithFormat:@"Amy's meme text editor\n\n%s\n\nPlease don't use this for real work...",stringify(gitHash)]);
}

-(BOOL)validateUserInterfaceItem:(NSObject<NSValidatedUserInterfaceItem>*)item
{
	if([item isKindOfClass:NSMenuItem.class])
	{
		NSMenuItem* menuItem=(NSMenuItem*)item;
		
		SettingsMapping* mapping=[Settings mappingWithName:menuItem.title];
		if(mapping)
		{
			menuItem.state=mapping.getValue?NSControlStateValueOn:NSControlStateValueOff;
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

@end
