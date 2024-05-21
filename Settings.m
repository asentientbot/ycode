@implementation Settings

+(NSArray<SettingsMapping*>*)allMappings
{
	// TODO: implement numeric settings, cases that need reload currently, etc
	
	return @[
		[SettingsMapping mappingWithName:@"Line Numbers" getter:@"showLineNumbers" defaultValue:true],
		[SettingsMapping mappingWithName:@"Code Folding" getter:@"showCodeFoldingSidebar" defaultValue:false],
		[SettingsMapping mappingWithName:@"Minimap (Needs Reload)" getter:@"showMinimap" defaultValue:true],
		[SettingsMapping mappingWithName:@"Page Guide" getter:@"showPageGuide" defaultValue:false],
		[SettingsMapping mappingWithName:@"Structure Headers" getter:@"showStructureHeaders" defaultValue:true],
		[SettingsMapping mappingWithName:@"Invisible Characters (Needs Reload)" getter:@"showInvisibleCharacters" defaultValue:false],
		[SettingsMapping mappingWithName:@"Indent Using Tabs" getter:@"useTabsToIndent" defaultValue:true],
		[SettingsMapping mappingWithName:@"Syntax-Aware Indentation" getter:@"useSyntaxAwareIndenting" defaultValue:false],
		[SettingsMapping mappingWithName:@"Close Block Comment" getter:@"autoCloseBlockComment" defaultValue:false],
		[SettingsMapping mappingWithName:@"Close Brace" getter:@"autoInsertClosingBrace" defaultValue:false],
		[SettingsMapping mappingWithName:@"Match Close Bracket" getter:@"autoInsertOpenBracket" defaultValue:false],
		[SettingsMapping mappingWithName:@"Type-Over Delimiters" getter:@"enableTypeOverCompletions" defaultValue:false],
		[SettingsMapping mappingWithName:@"Enclose Selection in Delimiters" getter:@"autoEncloseSelectionInDelimiters" defaultValue:false],
		[SettingsMapping mappingWithName:@"Soft Wrap Lines" getter:@"wrapLines" defaultValue:true],
		[SettingsMapping mappingWithName:@"Trim Trailing Whitespace" getter:@"trimTrailingWhitespace" defaultValue:true],
		[SettingsMapping mappingWithName:@"Suggest Completions" getter:@"autoSuggestCompletions" defaultValue:false],
		
		// TODO: doesn't work
		// [SettingsMapping mappingWithName:@"Completions on Esc" getter:@"showCompletionsOnEsc"],
		
		[SettingsMapping mappingWithName:@"Vi Mode" getter:@"useViKeyBindings" defaultValue:false],
	];
}

+(NSArray<NSString*>*)allNames
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

+(void)reset
{
	for(SettingsMapping* mapping in Settings.allMappings)
	{
		mapping.reset;
	}
}

@end
