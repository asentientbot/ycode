NSString* xcodePath=nil;

NSString* replaceXcodePath(NSString* path)
{
	if(!xcodePath)
	{
		xcodePath=[NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:@"com.apple.dt.Xcode"].path;
		if(!xcodePath)
		{
			alertAbort(@"xcode missing");
		}
	}
	
	return [path stringByReplacingOccurrencesOfString:@"%" withString:xcodePath];
}

void (*SoftInitialize)(int,NSError**);
Class SoftDocument;
Class SoftViewController;
Class SoftTheme;
Class SoftTheme2;
Class SoftSettings;
Class SoftSettings2;
Class SoftDocumentLocation;

@interface XcodeDocument:NSDocument

-(instancetype)initWithContentsOfURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error;

@end

@interface XcodeDocumentLocation:NSObject

-(instancetype)initWithDocumentURL:(NSURL*)url timestamp:(NSNumber*)timestamp characterRange:(NSRange)range;
-(NSRange)characterRange;

@end

@interface XcodeViewController:NSViewController

@property(retain) NSObject* representedExtension;
@property(retain) NSObject* fileTextSettings;

-(instancetype)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle document:(NSDocument*)document;
-(void)selectDocumentLocations:(NSArray<XcodeDocumentLocation*>*)locations;
-(NSArray<XcodeDocumentLocation*>*)currentSelectedDocumentLocations;
-(void)invalidate;

@end

@interface XcodeSettings:NSObject

+(instancetype)sharedPreferences;

@end

@class XcodeThemeManager;

#define XcodeThemeBackgroundKey @"DVTSourceTextBackground"
#define XcodeThemeHighlightKey @"DVTSourceTextCurrentLineHighlightColor"
#define XcodeThemeSelectionKey @"DVTSourceTextSelectionColor"
#define XcodeThemeCursorKey @"DVTSourceTextInsertionPointColor"
#define XcodeThemeInvisiblesKey @"DVTSourceTextInvisiblesColor"
#define XcodeThemeMarkdownCodeKey @"DVTMarkupTextInlineCodeColor"

#define XcodeThemeFontsKey @"DVTSourceTextSyntaxFonts"
#define XcodeThemeColorsKey @"DVTSourceTextSyntaxColors"
#define XcodeThemeCommentKeys @[@"xcode.syntax.comment",@"xcode.syntax.comment.doc",@"xcode.syntax.comment.doc.keyword",@"xcode.syntax.mark",@"xcode.syntax.url"]
#define XcodeThemePreprocessorKeys @[@"xcode.syntax.preprocessor"]
#define XcodeThemeClassKeys @[@"xcode.syntax.declaration.type"]
#define XcodeThemeFunctionKeys @[@"xcode.syntax.declaration.other",@"xcode.syntax.attribute"]
#define XcodeThemeKeywordKeys @[@"xcode.syntax.keyword"]
#define XcodeThemeStringKeys @[@"xcode.syntax.string"]
#define XcodeThemeNumberKeys @[@"xcode.syntax.number",@"xcode.syntax.character"]

@interface XcodeTheme2:NSObject

+(XcodeThemeManager*)preferenceSetsManager;
-(NSString*)localizedName;
-(NSString*)name;
-(BOOL)hasLightBackground;
-(NSColor*)sourceTextBackgroundColor;
-(NSColor*)sourceTextCurrentLineHighlightColor;
-(NSColor*)sourceTextSelectionColor;
-(NSColor*)sourcePlainTextColor;

@end

#define XcodeLightThemeKey @"XCFontAndColorCurrentTheme"
#define XcodeDarkThemeKey @"XCFontAndColorCurrentDarkTheme"
#define XcodeThemeChangedKey @"DVTFontAndColorSettingsChangedNotification"

@interface XcodeThemeManager:NSObject

@property(retain) XcodeTheme2* currentPreferenceSet;

-(NSArray<XcodeTheme2*>*)availablePreferenceSets;

@end

XcodeDocument* getXcodeDocument(NSURL* url,NSString* type)
{
	return [(XcodeDocument*)[SoftDocument alloc] initWithContentsOfURL:url ofType:type error:nil].autorelease;
}

XcodeViewController* getXcodeViewController(XcodeDocument* document)
{
	XcodeViewController* controller=[(XcodeViewController*)[SoftViewController alloc] initWithNibName:nil bundle:nil document:document].autorelease;
	controller.fileTextSettings=((NSObject*)[SoftSettings2 alloc]).init.autorelease;
	controller.view.clipsToBounds=true;
	return controller;
}

NSRange getXcodeViewControllerSelection(XcodeViewController* controller)
{
	XcodeDocumentLocation* location=controller.currentSelectedDocumentLocations.firstObject;
	return location?location.characterRange:NSMakeRange(0,0);
}

void focusXcodeViewController(XcodeViewController* controller,NSRange selection)
{
	NSURL* fakeURL=[NSURL.alloc initWithString:@""].autorelease;
	XcodeDocumentLocation* location=[(XcodeDocumentLocation*)[SoftDocumentLocation alloc] initWithDocumentURL:fakeURL timestamp:nil characterRange:selection].autorelease;
	[controller selectDocumentLocations:@[location]];
	
	// TODO: confusing. make a general "recurse views with block" function
	
	NSMutableArray<NSView*>* views=NSMutableArray.alloc.init.autorelease;
	[views addObject:controller.view];
	for(int index=0;index<views.count;index++)
	{
		if(views[index].acceptsFirstResponder)
		{
			[views[index].window makeFirstResponder:views[index]];
			break;
		}
		
		[views addObjectsFromArray:views[index].subviews];
	}
}

XcodeSettings* getXcodeSettings()
{
	return [SoftSettings sharedPreferences];
}

XcodeThemeManager* getXcodeThemeManager()
{
	return [SoftTheme2 preferenceSetsManager];
}

NSArray<XcodeTheme2*>* getXcodeThemes()
{
	return getXcodeThemeManager().availablePreferenceSets;
}

XcodeTheme2* getXcodeTheme()
{
	return getXcodeThemeManager().currentPreferenceSet;
}

void setXcodeTheme(XcodeTheme2* theme)
{
	getXcodeThemeManager().currentPreferenceSet=theme;
	
	[NSUserDefaults.standardUserDefaults setObject:theme.name forKey:XcodeLightThemeKey];
	[NSUserDefaults.standardUserDefaults setObject:theme.name forKey:XcodeDarkThemeKey];
}

NSString* getXcodeSystemThemesPath()
{
	for(NSString* format in @[@"%/Contents/SharedFrameworks/DVTUserInterfaceKit.framework/Versions/A/Resources/FontAndColorThemes",@"%/Contents/SharedFrameworks/DVTKit.framework/Versions/A/Resources/FontAndColorThemes"])
	{
		NSString* path=replaceXcodePath(format);
		if([NSFileManager.defaultManager fileExistsAtPath:path])
		{
			return path;
		}
	}
	
	alertAbort(@"system themes folder missing");
}

NSString* getXcodeUserThemesPath()
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/Xcode/UserData/FontAndColorThemes"];
}

NSMenu* (^contextMenuHook)()=NULL;
NSMenu* hackContextMenu()
{
	return contextMenuHook();
}

void linkLibrary(NSString* path)
{
	if(!dlopen(path.UTF8String,RTLD_LAZY))
	{
		alertAbort([NSString stringWithFormat:@"dlopen failed: %s",dlerror()]);
	}
}

void linkSymbol(NSString* name,void** pointer)
{
	void* symbol=dlsym(RTLD_DEFAULT,name.UTF8String);
	if(!symbol)
	{
		alertAbort([NSString stringWithFormat:@"dlsym failed: %s",dlerror()]);
	}
	*pointer=symbol;
}

void linkClass(NSString* name,Class* pointer)
{
	linkSymbol([NSString stringWithFormat:@"OBJC_CLASS_$_%@",name],(void**)pointer);
}

void linkXcode()
{
	linkLibrary(replaceXcodePath(@"%/Contents/PlugIns/IDESourceEditor.framework/Versions/A/IDESourceEditor"));
	
	linkSymbol(@"IDEInitialize",(void**)&SoftInitialize);
	linkClass(@"_TtC15IDESourceEditor18SourceCodeDocument",&SoftDocument);
	linkClass(@"_TtC15IDESourceEditor16SourceCodeEditor",&SoftViewController);
	linkClass(@"DVTTheme",&SoftTheme);
	linkClass(@"DVTFontAndColorTheme",&SoftTheme2);
	linkClass(@"DVTTextPreferences",&SoftSettings);
	linkClass(@"IDEFileTextSettings",&SoftSettings2);
	linkClass(@"DVTTextDocumentLocation",&SoftDocumentLocation);
	
	// TODO: stupid
	
	swizzle(@"IDEDocumentController",@"sharedDocumentController",false,(IMP)returnNil,NULL);
	swizzle(@"_TtC12SourceEditor16SourceEditorView",@"menuForEvent:",true,(IMP)hackContextMenu,NULL);
	
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

void restartIfNeeded(char** argv)
{
	// TODO: case where it's already set? maybe we should instead check if IDESourceEditor fails to load?
	
	if(!getenv("DYLD_FRAMEWORK_PATH"))
	{
		NSString* dylibPaths=replaceXcodePath(@"%/Contents/Frameworks:%/Contents/SharedFrameworks:%/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks:%/Contents/Developer/Library/Frameworks");
		setenv("DYLD_FRAMEWORK_PATH",dylibPaths.UTF8String,true);
		setenv("DYLD_LIBRARY_PATH",dylibPaths.UTF8String,true);
		execv(argv[0],argv);
		
		alertAbort(@"re-exec failed");
	}
}
