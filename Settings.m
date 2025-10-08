@implementation Settings

+(NSArray<SettingsMapping*>*)mappings
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

+(NSArray<NSString*>*)mappingNames
{
	return [Settings.mappings valueForKey:@"name"];
}

+(SettingsMapping*)mappingWithName:(NSString*)name
{
	for(SettingsMapping* mapping in Settings.mappings)
	{
		if([mapping.name isEqual:name])
		{
			return mapping;
		}
	}
	
	return nil;
}

+(NSString*)screenKey
{
	CGRect screenRect=NSScreen.mainScreen.frame;
	return [NSString stringWithFormat:@"screen %ld %ld %ld %ld",(long)screenRect.origin.x,(long)screenRect.origin.y,(long)screenRect.size.width,(long)screenRect.size.height];
}

+(NSString*)rectKeyWithPrefix:(NSString*)prefix suffix:(NSString*)suffix
{
	return [NSString stringWithFormat:@"%@ - %@ - %@",prefix,Settings.screenKey,suffix];
}

+(void)saveRect:(CGRect)rect withPrefix:(NSString*)prefix
{
	NSUserDefaults* defaults=NSUserDefaults.standardUserDefaults;
	[defaults setDouble:rect.origin.x forKey:[Settings rectKeyWithPrefix:prefix suffix:@"x"]];
	[defaults setDouble:rect.origin.y forKey:[Settings rectKeyWithPrefix:prefix suffix:@"y"]];
	[defaults setDouble:rect.size.width forKey:[Settings rectKeyWithPrefix:prefix suffix:@"width"]];
	[defaults setDouble:rect.size.height forKey:[Settings rectKeyWithPrefix:prefix suffix:@"height"]];
}

+(CGRect)rectWithPrefix:(NSString*)prefix
{
	NSUserDefaults* defaults=NSUserDefaults.standardUserDefaults;
	CGFloat x=[defaults doubleForKey:[Settings rectKeyWithPrefix:prefix suffix:@"x"]];
	CGFloat y=[defaults doubleForKey:[Settings rectKeyWithPrefix:prefix suffix:@"y"]];
	CGFloat width=[defaults doubleForKey:[Settings rectKeyWithPrefix:prefix suffix:@"width"]];
	CGFloat height=[defaults doubleForKey:[Settings rectKeyWithPrefix:prefix suffix:@"height"]];
	
	if(width<100||height<100)
	{
		return CGRectZero;
	}
	
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

+(BOOL)showedProjectModeExplanation
{
	return [NSUserDefaults.standardUserDefaults boolForKey:@"showed project mode explanation"];
}

+(void)setShowedProjectModeExplanation:(BOOL)value
{
	[NSUserDefaults.standardUserDefaults setBool:value forKey:@"showed project mode explanation"];
}

+(void)reset
{
	for(SettingsMapping* mapping in Settings.mappings)
	{
		mapping.reset;
	}
	
	[Xcode saveThemeWithName:AppName backgroundColor:AmyThemeBackgroundColorTranslucent highlightColor:AmyThemeHighlightColor selectionColor:AmyThemeSelectionColor defaultFont:AmyThemeRegularFont defaultColor:AmyThemeNormalColor commentFont:AmyThemeItalicFont commentColor:AmyThemeMetaColor preprocessorFont:AmyThemeRegularFont preprocessorColor:AmyThemeMetaColor classFont:AmyThemeBoldFont classColor:AmyThemeTypeColor functionFont:AmyThemeBoldFont functionColor:AmyThemeTypeColor keywordFont:AmyThemeBoldFont keywordColor:AmyThemeKeywordColor stringFont:AmyThemeBoldFont stringColor:AmyThemeStringColor numberFont:AmyThemeBoldFont numberColor:AmyThemeNumberColor];
	Xcode.themeName=AppName;
	
	Settings.showedProjectModeExplanation=false;
}

+(void)checkFirstRun
{
	if(![NSUserDefaults.standardUserDefaults boolForKey:@"launched"])
	{
		[NSUserDefaults.standardUserDefaults setBool:true forKey:@"launched"];
		
		Settings.reset;
	}
}

+(NSColor*)colorWithString:(NSString*)string
{
	NSArray<NSString*>* bits=[string componentsSeparatedByString:@" "];
	
	CGFloat red=bits[0].doubleValue;
	CGFloat green=bits[1].doubleValue;
	CGFloat blue=bits[2].doubleValue;
	CGFloat alpha=bits.count==4?bits[3].doubleValue:1;
	
	CGColorRef cgColor=CGColorCreateGenericRGB(red,green,blue,alpha);
	NSColor* appkitColor=[NSColor colorWithCGColor:cgColor];
	CFRelease(cgColor);
	
	return appkitColor;
}

+(void)saveAppIcon
{
	CGColorRef backgroundColor=[Settings colorWithString:AmyThemeBackgroundColorOpaque].CGColor;
	CGColorRef strokeColor=[Settings colorWithString:AmyThemeNormalColor].CGColor;
	CGColorRef fillColor=[Settings colorWithString:AmyThemeHighlightColor].CGColor;
	
	CGRect rect=CGRectMake(0,0,1024,1024);
	
	CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(NULL,1024,1024,8,1024*4,space,(CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	
	CALayer* container=CALayer.layer;
	container.frame=rect;
	CALayer* round=CALayer.layer;
	round.frame=CGRectMake(100,100,824,824);
	round.backgroundColor=backgroundColor;
	round.cornerRadius=186;
	if(@available(macOS 10.15,*))
	{
		round.cornerCurve=kCACornerCurveContinuous;
	}
	round.shadowOpacity=0.25;
	round.shadowRadius=10;
	round.shadowOffset=CGSizeMake(0,-10);
	[container addSublayer:round];
	[container renderInContext:context];
	
	CGContextSetLineJoin(context,kCGLineJoinRound);
	CGContextSetLineWidth(context,30);
	CGContextSetTextDrawingMode(context,kCGTextFillStroke);
	CGContextSetFillColorWithColor(context,fillColor);
	CGContextSetStrokeColorWithColor(context,strokeColor);
	CGContextSelectFont(context,"Futura-Bold",650,kCGEncodingMacRoman);
	CGContextShowTextAtPoint(context,290,410,"y",1);
	
	CGImageRef image=CGBitmapContextCreateImage(context);
	
	NSURL* url=[NSURL fileURLWithPath:@"icon.png"];
	CGImageDestinationRef destination=CGImageDestinationCreateWithURL((CFURLRef)url,kUTTypePNG,1,NULL);
	CGImageDestinationAddImage(destination,image,NULL);
	CGImageDestinationFinalize(destination);
	
	CFRelease(destination);
	CFRelease(image);
	CFRelease(context);
	CFRelease(space);
}

+(NSData*)terminalColorDataWithString:(NSString*)string
{
	return [NSKeyedArchiver archivedDataWithRootObject:[Settings colorWithString:string] requiringSecureCoding:false error:nil];
}

+(void)saveTerminalTheme
{
	NSDictionary* theme=@{
		@"type":@"Window Settings",
		@"name":AppName,
		
		@"Font":[NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:AmyThemeTerminalFont size:AmyThemeTerminalFontSize] requiringSecureCoding:false error:nil],
		
		@"BackgroundBlur":@AmyThemeTerminalBlurAmount,
		
		@"BackgroundColor":[Settings terminalColorDataWithString:AmyThemeTerminalBackgroundColor],
		@"SelectionColor":[Settings terminalColorDataWithString:AmyThemeSelectionColor],
		@"TextColor":[Settings terminalColorDataWithString:AmyThemeNormalColor],
		@"TextBoldColor":[Settings terminalColorDataWithString:AmyThemeNormalColor],
		@"CursorColor":[Settings terminalColorDataWithString:AmyThemeNormalColor]
	};
	
	assert([theme writeToURL:[NSURL fileURLWithPath:[AppName stringByAppendingString:@".terminal"]] error:nil]);
}

@end
