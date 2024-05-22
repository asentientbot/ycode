@implementation ThemeMapping

-(void)saveWithName:(NSString*)name
{
	NSData* baseData=nil;
	for(NSString* possiblePath in @[@"%/Contents/SharedFrameworks/DVTUserInterfaceKit.framework/Versions/A/Resources/FontAndColorThemes/Default (Light).xccolortheme",@"%/Contents/SharedFrameworks/DVTKit.framework/Versions/A/Resources/FontAndColorThemes/Default (Light).xccolortheme"])
	{
		NSString* basePath=replaceXcodePath(possiblePath);
		baseData=[NSData dataWithContentsOfFile:basePath];
		if(baseData)
		{
			break;
		}
	}
	if(!baseData)
	{
		alertAbort(@"base theme missing");
	}
	
	NSMutableDictionary* custom=[NSPropertyListSerialization propertyListWithData:baseData options:NSPropertyListMutableContainers format:nil error:nil];
	if(!custom)
	{
		alertAbort(@"base theme broken");
	}
	
	custom[@"DVTSourceTextBackground"]=self.backgroundColor;
	custom[@"DVTSourceTextCurrentLineHighlightColor"]=self.highlightColor;
	custom[@"DVTSourceTextSelectionColor"]=self.selectionColor;
	
	custom[@"DVTSourceTextInsertionPointColor"]=self.defaultColor;
	custom[@"DVTSourceTextInvisiblesColor"]=self.commentColor;
	
	NSMutableDictionary* innerFonts=custom[@"DVTSourceTextSyntaxFonts"];
	NSMutableDictionary* innerColors=custom[@"DVTSourceTextSyntaxColors"];
	for(NSString* key in innerColors.allKeys)
	{
		NSString* font=self.defaultFont;
		NSString* color=self.defaultColor;
		
		if([@[@"xcode.syntax.comment",@"xcode.syntax.comment.doc",@"xcode.syntax.comment.doc.keyword",@"xcode.syntax.mark",@"xcode.syntax.url"] containsObject:key])
		{
			font=self.commentFont;
			color=self.commentColor;
		}
		else if([@[@"xcode.syntax.preprocessor"] containsObject:key])
		{
			font=self.preprocessorFont;
			color=self.preprocessorColor;
		}
		else if([@[@"xcode.syntax.declaration.type"] containsObject:key])
		{
			// TODO: these don't work on Zoe, but they also don't in Xcode, so
			
			font=self.classFont;
			color=self.classColor;
		}
		else if([@[@"xcode.syntax.declaration.other",@"xcode.syntax.attribute"] containsObject:key])
		{
			font=self.functionFont;
			color=self.functionColor;
		}
		else if([@[@"xcode.syntax.keyword"] containsObject:key])
		{
			font=self.keywordFont;
			color=self.keywordColor;
		}
		else if([@[@"xcode.syntax.string"] containsObject:key])
		{
			font=self.stringFont;
			color=self.stringColor;
		}
		else if([@[@"xcode.syntax.number",@"xcode.syntax.character"] containsObject:key])
		{
			font=self.numberFont;
			color=self.numberColor;
		}
		
		innerFonts[key]=font;
		innerColors[key]=color;
	}
	
	NSString* customPath=[NSString stringWithFormat:@"%@/Library/Developer/Xcode/UserData/FontAndColorThemes/%@.xccolortheme",NSHomeDirectory(),name];
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
