@implementation Settings

+(NSArray<SettingsMapping*>*)allMappings
{
	// TODO: implement numeric settings, cases that need reload currently, etc
	
	return @[
		[SettingsMapping mappingWithName:@"Show Line Numbers" getter:@"showLineNumbers" defaultValue:true],
		[SettingsMapping mappingWithName:@"Show Folding Sidebar" getter:@"showCodeFoldingSidebar" defaultValue:false],
		[SettingsMapping mappingWithName:@"Show Minimap (May Need Reload)" getter:@"showMinimap" defaultValue:true],
		[SettingsMapping mappingWithName:@"Show Page Guide" getter:@"showPageGuide" defaultValue:false],
		[SettingsMapping mappingWithName:@"Show Structure Headers" getter:@"showStructureHeaders" defaultValue:true],
		[SettingsMapping mappingWithName:@"Show Invisible Characters (May Need Reload)" getter:@"showInvisibleCharacters" defaultValue:false],
		[SettingsMapping mappingWithName:@"Fade Comment Delimiters" getter:@"fadeCommentDelimiters" defaultValue:false],
		[SettingsMapping mappingWithName:@"Indent Using Tabs" getter:@"useTabsToIndent" defaultValue:true],
		[SettingsMapping mappingWithName:@"Use Syntax-Aware Indentation" getter:@"useSyntaxAwareIndenting" defaultValue:false],
		[SettingsMapping mappingWithName:@"Close Block Comments" getter:@"autoCloseBlockComment" defaultValue:false],
		[SettingsMapping mappingWithName:@"Close Braces" getter:@"autoInsertClosingBrace" defaultValue:false],
		[SettingsMapping mappingWithName:@"Match Closing Brackets" getter:@"autoInsertOpenBracket" defaultValue:false],
		[SettingsMapping mappingWithName:@"Use Type-Over Delimiters" getter:@"enableTypeOverCompletions" defaultValue:false],
		[SettingsMapping mappingWithName:@"Enclose Selection in Delimiters" getter:@"autoEncloseSelectionInDelimiters" defaultValue:false],
		[SettingsMapping mappingWithName:@"Soft Wrap Lines" getter:@"wrapLines" defaultValue:true],
		[SettingsMapping mappingWithName:@"Trim Trailing Whitespace" getter:@"trimTrailingWhitespace" defaultValue:true],
		[SettingsMapping mappingWithName:@"Suggest Completions" getter:@"autoSuggestCompletions" defaultValue:false],
		[SettingsMapping mappingWithName:@"Use Vi Mode" getter:@"useViKeyBindings" defaultValue:false]
	];
}

+(NSArray<NSString*>*)allMappingNames
{
	return [Settings.allMappings valueForKey:@"name"];
}

+(SettingsMapping*)mappingWithName:(NSString*)name
{
	for(SettingsMapping* mapping in Settings.allMappings)
	{
		if([mapping.name isEqual:name])
		{
			return mapping;
		}
	}
	
	return nil;
}

+(NSArray<NSString*>*)allThemeNames
{
	NSArray<NSString*>* names=[getXcodeThemes() valueForKeyPath:@"localizedName"];
	return [names sortedArrayUsingSelector:@selector(compare:)];
}

+(NSString*)currentThemeName
{
	return getXcodeTheme().localizedName;
}

+(void)setCurrentThemeName:(NSString*)name
{
	XcodeTheme2* matched=nil;
	
	for(XcodeTheme2* theme in getXcodeThemes())
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
	
	setXcodeTheme(matched);
}

+(void)saveRect:(CGRect)rect withPrefix:(NSString*)prefix
{
	NSUserDefaults* defaults=NSUserDefaults.standardUserDefaults;
	[defaults setDouble:rect.origin.x forKey:[prefix stringByAppendingString:@".x"]];
	[defaults setDouble:rect.origin.y forKey:[prefix stringByAppendingString:@".y"]];
	[defaults setDouble:rect.size.width forKey:[prefix stringByAppendingString:@".width"]];
	[defaults setDouble:rect.size.height forKey:[prefix stringByAppendingString:@".height"]];
}

+(CGRect)rectWithPrefix:(NSString*)prefix
{
	NSUserDefaults* defaults=NSUserDefaults.standardUserDefaults;
	CGFloat x=[defaults doubleForKey:[prefix stringByAppendingString:@".x"]];
	CGFloat y=[defaults doubleForKey:[prefix stringByAppendingString:@".y"]];
	CGFloat width=[defaults doubleForKey:[prefix stringByAppendingString:@".width"]];
	CGFloat height=[defaults doubleForKey:[prefix stringByAppendingString:@".height"]];
	return CGRectMake(x,y,width,height);
}

+(void)setProjectRect:(CGRect)rect
{
	[Settings saveRect:rect withPrefix:@"project"];
}

+(CGRect)projectRect
{
	return [Settings rectWithPrefix:@"project"];
}

+(void)saveThemeWithName:(NSString*)name backgroundColor:(NSString*)backgroundColor highlightColor:(NSString*)highlightColor selectionColor:(NSString*)selectionColor defaultFont:(NSString*)defaultFont defaultColor:(NSString*)defaultColor commentFont:(NSString*)commentFont commentColor:(NSString*)commentColor preprocessorFont:(NSString*)preprocessorFont preprocessorColor:(NSString*)preprocessorColor classFont:(NSString*)classFont classColor:(NSString*)classColor functionFont:(NSString*)functionFont functionColor:(NSString*)functionColor keywordFont:(NSString*)keywordFont keywordColor:(NSString*)keywordColor stringFont:(NSString*)stringFont stringColor:(NSString*)stringColor numberFont:(NSString*)numberFont numberColor:(NSString*)numberColor
{
	NSString* basePath=[getXcodeSystemThemesPath() stringByAppendingPathComponent:@"Default (Light).xccolortheme"];
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
	
	NSString* customPath=[getXcodeUserThemesPath() stringByAppendingPathComponent:[name stringByAppendingString:@".xccolortheme"]];
	[NSFileManager.defaultManager createDirectoryAtPath:customPath.stringByDeletingLastPathComponent withIntermediateDirectories:true attributes:nil error:nil];
	
	NSData* customData=[NSPropertyListSerialization dataWithPropertyList:custom format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
	if(![customData writeToFile:customPath atomically:true])
	{
		alertAbort(@"theme write failed");
	}
}

+(NSString*)simpleThemeNameWithSuffix:(NSString*)suffix
{
	return [NSString stringWithFormat:@"%@ %@",getAppName(),suffix];
}

+(void)saveSimpleThemeWithSuffix:(NSString*)suffix background:(NSString*)backgroundColor highlight:(NSString*)highlightColor selection:(NSString*)selectionColor normal:(NSString*)normalColor meta:(NSString*)metaColor type:(NSString*)typeColor keyword:(NSString*)keywordColor string:(NSString*)stringColor number:(NSString*)numberColor
{
	NSString* regular=@"SFMono-Regular - 13.0";
	NSString* italic=@"SFMono-RegularItalic - 13.0";
	NSString* bold=@"SFMono-Bold - 13.0";
	
	[Settings saveThemeWithName:[Settings simpleThemeNameWithSuffix:suffix] backgroundColor:backgroundColor highlightColor:highlightColor selectionColor:selectionColor defaultFont:regular defaultColor:normalColor commentFont:italic commentColor:metaColor preprocessorFont:regular preprocessorColor:metaColor classFont:bold classColor:typeColor functionFont:regular functionColor:typeColor keywordFont:bold keywordColor:keywordColor stringFont:bold stringColor:stringColor numberFont:bold numberColor:numberColor];
}

+(void)reset
{
	for(SettingsMapping* mapping in Settings.allMappings)
	{
		mapping.reset;
	}
	
	[Settings saveSimpleThemeWithSuffix:@"Neutral" background:@"1 1 1" highlight:@"0.95 0.95 1" selection:@"0.8 0.8 1" normal:@"0.3 0.3 0.6" meta:@"0.5 0.5 0.8" type:@"0.6 0.1 1" keyword:@"0.8 0.2 0.4" string:@"0.9 0.4 0.9" number:@"0.2 0.5 1"];
	
	[Settings setCurrentThemeName:[Settings simpleThemeNameWithSuffix:@"Neutral"]];
}

@end
