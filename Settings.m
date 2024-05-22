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
	NSArray<NSString*>* names=[getXcodeThemeManager().availablePreferenceSets valueForKeyPath:@"localizedName"];
	return [names sortedArrayUsingSelector:@selector(compare:)];
}

+(NSString*)currentThemeName
{
	return getXcodeThemeManager().currentPreferenceSet.localizedName;
}

+(void)setCurrentThemeName:(NSString*)name
{
	for(XcodeTheme2* theme in getXcodeThemeManager().availablePreferenceSets)
	{
		if([theme.localizedName isEqual:name])
		{
			getXcodeThemeManager().currentPreferenceSet=theme;
			break;
		}
	}
}

+(void)reset
{
	for(SettingsMapping* mapping in Settings.allMappings)
	{
		mapping.reset;
	}
	
	Settings.setSampleTheme;
}

+(void)setSampleTheme
{
	ThemeMapping* theme=ThemeMapping.alloc.init.autorelease;
	
	NSString* regular=@"SFMono-Regular - 13.0";
	NSString* italic=@"SFMono-RegularItalic - 13.0";
	NSString* bold=@"SFMono-Bold - 13.0";
	
	theme.defaultFont=regular;
	theme.defaultColor=@"0.3 0.3 0.6 1";
	
	theme.backgroundColor=@"1 0.94 1 1";
	theme.highlightColor=@"1 0.88 1 1";
	theme.selectionColor=@"1 0.82 1 1";
	
	theme.commentFont=italic;
	theme.commentColor=@"0.4 0.4 0.8 1";
	theme.preprocessorFont=regular;
	theme.preprocessorColor=theme.commentColor;
	theme.classFont=bold;
	theme.classColor=@"0 0.6 0.5 1";
	theme.functionFont=regular;
	theme.functionColor=theme.classColor;
	theme.keywordFont=bold;
	theme.keywordColor=@"0.8 0 0.9 1";
	theme.stringFont=bold;
	theme.stringColor=@"0.9 0.4 0.8 1";
	theme.numberFont=bold;
	theme.numberColor=@"0.3 0.6 1 1";
	
	[theme saveWithName:getAppName()];
	[Settings setCurrentThemeName:getAppName()];
}

@end
