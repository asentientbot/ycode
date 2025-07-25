id hackReturnNil()
{
	return nil;
}

NSMenu* hackContextMenu()
{
	return contextMenuHook();
}

@implementation Xcode

+(NSString*)replacePath:(NSString*)template
{
	if(!xcodePath)
	{
		xcodePath=[NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:@"com.apple.dt.Xcode"].path;
		if(!xcodePath)
		{
			alertAbort(@"xcode missing");
		}
	}
	
	return [template stringByReplacingOccurrencesOfString:@"%" withString:xcodePath];
}

+(XcodeDocument*)documentWithURL:(NSURL*)url type:(NSString*)type
{
	return [(XcodeDocument*)SoftDocument.alloc initWithContentsOfURL:url ofType:type error:nil].autorelease;
}

+(void)destroyDocument:(XcodeDocument*)document
{
	document.retain;
	
	dispatch_async(dispatch_get_main_queue(),^()
	{
		document.close;
		document.release;
	});
}

+(XcodeViewController*)viewControllerWithDocument:(XcodeDocument*)document
{
	XcodeViewController* controller=[(XcodeViewController*)SoftViewController.alloc initWithNibName:nil bundle:nil document:document].autorelease;
	
	// TODO: needed for trimming whitespace, weird
	
	controller.fileTextSettings=((NSObject*)SoftSettings2.alloc).init.autorelease;
	
	return controller;
}

+(NSRange)selectionWithViewController:(XcodeViewController*)controller
{
	XcodeDocumentLocation* location=controller.currentSelectedDocumentLocations.firstObject;
	return location?location.characterRange:NSMakeRange(0,0);
}

+(void)focusViewController:(XcodeViewController*)controller withSelection:(NSRange)selection
{
	NSURL* fakeURL=[NSURL.alloc initWithString:@""].autorelease;
	XcodeDocumentLocation* location=[(XcodeDocumentLocation*)SoftDocumentLocation.alloc initWithDocumentURL:fakeURL timestamp:nil characterRange:selection].autorelease;
	[controller selectDocumentLocations:@[location]];
	
	// TODO: hack to load views in time for takeFocus
		
	controller.view.window.display;
	
	controller.takeFocus;
}

+(void)destroyViewController:(XcodeViewController*)controller
{
	// TODO: fixes a memory leak closing tabs (not windows)
	
	assert(controller.view.window);
	controller.view.display;
	
	controller.view.removeFromSuperview;
	controller.invalidate;
}

+(XcodeSettings*)settings
{
	return [SoftSettings sharedPreferences];
}

+(NSArray<XcodeTheme2*>*)themes
{
	return [SoftTheme2 preferenceSetsManager].availablePreferenceSets;
}

+(NSArray<NSString*>*)themeNames
{
	NSArray<NSString*>* names=[Xcode.themes valueForKey:@"localizedName"];
	return [names sortedArrayUsingSelector:@selector(compare:)];
}

+(XcodeTheme2*)theme
{
	return [SoftTheme2 preferenceSetsManager].currentPreferenceSet;
}

+(NSString*)themeName
{
	return Xcode.theme.localizedName;
}

+(BOOL)themeIsLight
{
	return Xcode.theme.hasLightBackground;
}

+(void)setTheme:(XcodeTheme2*)theme
{
	[SoftTheme2 preferenceSetsManager].currentPreferenceSet=theme;
	
	[NSUserDefaults.standardUserDefaults setObject:theme.name forKey:XcodeLightThemeKey];
	[NSUserDefaults.standardUserDefaults setObject:theme.name forKey:XcodeDarkThemeKey];
}

+(void)setThemeName:(NSString*)name
{
	XcodeTheme2* matched=nil;
	
	for(XcodeTheme2* theme in Xcode.themes)
	{
		if([theme.localizedName isEqual:name])
		{
			matched=theme;
			break;
		}
	}
	
	if(!matched)
	{
		alert(@"theme missing");
		return;
	}
	
	Xcode.theme=matched;
}

+(NSString*)systemThemesPath
{
	for(NSString* template in @[@"%/Contents/SharedFrameworks/DVTUserInterfaceKit.framework/Versions/A/Resources/FontAndColorThemes",@"%/Contents/SharedFrameworks/DVTKit.framework/Versions/A/Resources/FontAndColorThemes"])
	{
		NSString* path=[Xcode replacePath:template];
		if([NSFileManager.defaultManager fileExistsAtPath:path])
		{
			return path;
		}
	}
	
	alertAbort(@"system themes folder missing");
}

+(NSString*)userThemesPath
{
	return @"~/Library/Developer/Xcode/UserData/FontAndColorThemes".stringByExpandingTildeInPath;
}

+(void)saveThemeWithName:(NSString*)name backgroundColor:(NSString*)backgroundColor highlightColor:(NSString*)highlightColor selectionColor:(NSString*)selectionColor defaultFont:(NSString*)defaultFont defaultColor:(NSString*)defaultColor commentFont:(NSString*)commentFont commentColor:(NSString*)commentColor preprocessorFont:(NSString*)preprocessorFont preprocessorColor:(NSString*)preprocessorColor classFont:(NSString*)classFont classColor:(NSString*)classColor functionFont:(NSString*)functionFont functionColor:(NSString*)functionColor keywordFont:(NSString*)keywordFont keywordColor:(NSString*)keywordColor stringFont:(NSString*)stringFont stringColor:(NSString*)stringColor numberFont:(NSString*)numberFont numberColor:(NSString*)numberColor
{
	NSString* basePath=[Xcode.systemThemesPath stringByAppendingPathComponent:@"Default (Light).xccolortheme"];
	NSData* baseData=[NSData dataWithContentsOfFile:basePath];
	if(!baseData)
	{
		alertAbort(@"base theme missing");
	}
	
	NSMutableDictionary* custom=[NSPropertyListSerialization propertyListWithData:baseData options:NSPropertyListMutableContainers format:nil error:nil];
	if(!custom)
	{
		alertAbort(@"base theme broken");
	}
	
	custom[XcodeThemeBackgroundKey]=backgroundColor;
	custom[XcodeThemeHighlightKey]=highlightColor;
	custom[XcodeThemeSelectionKey]=selectionColor;
	custom[XcodeThemeCursorKey]=defaultColor;
	custom[XcodeThemeInvisiblesKey]=commentColor;
	custom[XcodeThemeMarkdownCodeKey]=stringColor;
	
	NSMutableDictionary* innerFonts=custom[XcodeThemeFontsKey];
	NSMutableDictionary* innerColors=custom[XcodeThemeColorsKey];
	for(NSString* key in innerColors.allKeys)
	{
		NSString* font=defaultFont;
		NSString* color=defaultColor;
		
		if([XcodeThemeCommentKeys containsObject:key])
		{
			font=commentFont;
			color=commentColor;
		}
		else if([XcodeThemePreprocessorKeys containsObject:key])
		{
			font=preprocessorFont;
			color=preprocessorColor;
		}
		else if([XcodeThemeClassKeys containsObject:key])
		{
			font=classFont;
			color=classColor;
		}
		else if([XcodeThemeFunctionKeys containsObject:key])
		{
			font=functionFont;
			color=functionColor;
		}
		else if([XcodeThemeKeywordKeys containsObject:key])
		{
			font=keywordFont;
			color=keywordColor;
		}
		else if([XcodeThemeStringKeys containsObject:key])
		{
			font=stringFont;
			color=stringColor;
		}
		else if([XcodeThemeNumberKeys containsObject:key])
		{
			font=numberFont;
			color=numberColor;
		}
		
		innerFonts[key]=font;
		innerColors[key]=color;
	}
	
	NSString* customPath=[Xcode.userThemesPath stringByAppendingPathComponent:[name stringByAppendingString:@".xccolortheme"]];
	[NSFileManager.defaultManager createDirectoryAtPath:customPath.stringByDeletingLastPathComponent withIntermediateDirectories:true attributes:nil error:nil];
	
	NSData* customData=[NSPropertyListSerialization dataWithPropertyList:custom format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
	if(![customData writeToFile:customPath atomically:true])
	{
		alertAbort(@"theme write failed");
	}
}

+(void)addThemeChangeHandler:(void (^)())handler
{
	void (^leakedHandler)()=[handler copy];
	
	[NSNotificationCenter.defaultCenter addObserverForName:XcodeThemeChangedKey object:nil queue:nil usingBlock:^(NSNotification* note)
	{
		leakedHandler();
	}];
}

+(void)setContextMenuHook:(NSMenu* (^)())block
{
	contextMenuHook=[block copy];
}

+(void)linkLibrary:(NSString*)path
{
	if(!dlopen(path.UTF8String,RTLD_LAZY))
	{
		alertAbort([NSString stringWithFormat:@"dlopen failed: %s",dlerror()]);
	}
}

+(void*)linkSymbol:(NSString*)name
{
	void* symbol=dlsym(RTLD_DEFAULT,name.UTF8String);
	if(!symbol)
	{
		alertAbort([NSString stringWithFormat:@"dlsym failed: %s",dlerror()]);
	}
	
	return symbol;
}

+(Class)linkClass:(NSString*)name
{
	return [Xcode linkSymbol:[NSString stringWithFormat:@"OBJC_CLASS_$_%@",name]];
}

+(IMP)swizzleWithClass:(NSString*)className selector:(NSString*)selName isInstance:(BOOL)isInstance implementation:(IMP)newImp
{
	Class class=NSClassFromString(className);
	if(!class)
	{
		alertAbort(@"swizzle class missing");
	}
	
	SEL sel=NSSelectorFromString(selName);
	Method method=(isInstance?class_getInstanceMethod:class_getClassMethod)(class,sel);
	if(!method)
	{
		alertAbort(@"swizzle method missing");
	}
	
	return method_setImplementation(method,newImp);
}

+(void)setupWithArgv:(char**)argv
{
	// TODO: case where it's already set? maybe we should instead check if IDESourceEditor fails to load?
	
	if(!getenv("DYLD_FRAMEWORK_PATH"))
	{
		NSString* dylibPaths=[Xcode replacePath:@"%/Contents/Frameworks:%/Contents/SharedFrameworks:%/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks:%/Contents/Developer/Library/Frameworks"];
		setenv("DYLD_FRAMEWORK_PATH",dylibPaths.UTF8String,true);
		setenv("DYLD_LIBRARY_PATH",dylibPaths.UTF8String,true);
		execv(argv[0],argv);
		
		alertAbort(@"re-exec failed");
	}
	
	[Xcode linkLibrary:[Xcode replacePath:@"%/Contents/PlugIns/IDESourceEditor.framework/Versions/A/IDESourceEditor"]];
	
	SoftInitialize=[Xcode linkSymbol:@"IDEInitialize"];
	
	SoftDocument=[Xcode linkClass:@"_TtC15IDESourceEditor18SourceCodeDocument"];
	SoftViewController=[Xcode linkClass:@"_TtC15IDESourceEditor16SourceCodeEditor"];
	SoftTheme=[Xcode linkClass:@"DVTTheme"];
	SoftTheme2=[Xcode linkClass:@"DVTFontAndColorTheme"];
	SoftSettings=[Xcode linkClass:@"DVTTextPreferences"];
	SoftSettings2=[Xcode linkClass:@"IDEFileTextSettings"];
	SoftDocumentLocation=[Xcode linkClass:@"DVTTextDocumentLocation"];
	
	// TODO: stupid
	
	[Xcode swizzleWithClass:@"IDEDocumentController" selector:@"sharedDocumentController" isInstance:false implementation:(IMP)hackReturnNil];
	[Xcode swizzleWithClass:@"_TtC12SourceEditor16SourceEditorView" selector:@"menuForEvent:" isInstance:true implementation:(IMP)hackContextMenu];
	
	// TODO: aborts if Xcode present but never opened
	
	NSError* error=nil;
	SoftInitialize(0,&error);
	if(error)
	{
		alertAbort([NSString stringWithFormat:@"xcode init failed: %@",error]);
	}
	
	// TODO: is there a more normal way to call this?
	
	[SoftTheme initialize];
	
	// TODO: still missing xcode indexing-based colors
	// TODO: source control sidebar?
}

@end
