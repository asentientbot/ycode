@implementation ThemeMapping

-(void)saveWithName:(NSString*)name
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
	
	custom[XcodeThemeBackgroundKey]=self.backgroundColor;
	custom[XcodeThemeHighlightKey]=self.highlightColor;
	custom[XcodeThemeSelectionKey]=self.selectionColor;
	custom[XcodeThemeCursorKey]=self.defaultColor;
	custom[XcodeThemeInvisiblesKey]=self.commentColor;
	
	NSMutableDictionary* innerFonts=custom[XcodeThemeFontsKey];
	NSMutableDictionary* innerColors=custom[XcodeThemeColorsKey];
	for(NSString* key in innerColors.allKeys)
	{
		NSString* font=self.defaultFont;
		NSString* color=self.defaultColor;
		
		if([XcodeThemeCommentKeys containsObject:key])
		{
			font=self.commentFont;
			color=self.commentColor;
		}
		else if([XcodeThemePreprocessorKeys containsObject:key])
		{
			font=self.preprocessorFont;
			color=self.preprocessorColor;
		}
		else if([XcodeThemeClassKeys containsObject:key])
		{
			font=self.classFont;
			color=self.classColor;
		}
		else if([XcodeThemeFunctionKeys containsObject:key])
		{
			font=self.functionFont;
			color=self.functionColor;
		}
		else if([XcodeThemeKeywordKeys containsObject:key])
		{
			font=self.keywordFont;
			color=self.keywordColor;
		}
		else if([XcodeThemeStringKeys containsObject:key])
		{
			font=self.stringFont;
			color=self.stringColor;
		}
		else if([XcodeThemeNumberKeys containsObject:key])
		{
			font=self.numberFont;
			color=self.numberColor;
		}
		
		innerFonts[key]=font;
		innerColors[key]=[color stringByAppendingString:@" 1"];
	}
	
	NSString* customPath=[getXcodeUserThemesPath() stringByAppendingPathComponent:[name stringByAppendingString:@".xccolortheme"]];
	[NSFileManager.defaultManager createDirectoryAtPath:customPath.stringByDeletingLastPathComponent withIntermediateDirectories:true attributes:nil error:nil];
	
	NSData* customData=[NSPropertyListSerialization dataWithPropertyList:custom format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
	if(![customData writeToFile:customPath atomically:true])
	{
		alertAbort(@"theme write failed");
	}
}

-(void)dealloc
{
	self.defaultFont=nil;
	self.defaultColor=nil;
	
	self.backgroundColor=nil;
	self.highlightColor=nil;
	self.selectionColor=nil;
	
	self.commentFont=nil;
	self.commentColor=nil;
	self.preprocessorFont=nil;
	self.preprocessorColor=nil;
	self.classFont=nil;
	self.classColor=nil;
	self.functionFont=nil;
	self.functionColor=nil;
	self.keywordFont=nil;
	self.keywordColor=nil;
	self.stringFont=nil;
	self.stringColor=nil;
	self.numberFont=nil;
	self.numberColor=nil;
	
	super.dealloc;
}

@end
