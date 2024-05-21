// TODO: configurable?

NSString* xcodePath=@"/Applications/Xcode.app";
NSString* xcodePathPlaceholder=@"%";

NSString* replaceXcodePath(NSString* path)
{
	return [path stringByReplacingOccurrencesOfString:xcodePathPlaceholder withString:xcodePath];
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

@end

@interface XcodeViewController:NSViewController

@property(retain) NSObject* representedExtension;
@property(retain) NSObject* fileTextSettings;

-(instancetype)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle document:(NSDocument*)document;
-(void)selectDocumentLocations:(NSArray<XcodeDocumentLocation*>*)locations;

@end

@interface XcodeSettings:NSObject

+(instancetype)sharedPreferences;

@end

@class XcodeThemeManager;

@interface XcodeTheme2:NSObject

+(XcodeThemeManager*)preferenceSetsManager;
-(NSString*)localizedName;

@end

@interface XcodeThemeManager:NSObject

@property(retain) XcodeTheme2* currentPreferenceSet;

-(NSArray<XcodeTheme2*>*)availablePreferenceSets;

@end

XcodeDocument* getXcodeDocument(NSURL* url,NSString* type)
{
	return [(XcodeDocument*)[SoftDocument alloc] initWithContentsOfURL:url ofType:type error:nil].autorelease;
}

// TODO: uhh

@interface HackExtension:NSObject
@end

@implementation HackExtension

-(NSString*)identifier
{
	return @"";
}

@end

XcodeViewController* getXcodeViewController(XcodeDocument* document)
{
	XcodeViewController* controller=[(XcodeViewController*)[SoftViewController alloc] initWithNibName:nil bundle:nil document:document].autorelease;
	
	controller.representedExtension=HackExtension.alloc.init.autorelease;
	controller.fileTextSettings=((NSObject*)[SoftSettings2 alloc]).init.autorelease;
	
	return controller;
}

// TODO: weird to separate from above, but asserts view loaded..

void focusXcodeViewController(XcodeViewController* controller)
{
	NSURL* fakeURL=[NSURL.alloc initWithString:@""].autorelease;
	XcodeDocumentLocation* location=[(XcodeDocumentLocation*)[SoftDocumentLocation alloc] initWithDocumentURL:fakeURL timestamp:nil characterRange:NSMakeRange(0,0)].autorelease;
	[controller selectDocumentLocations:@[location]];
}

XcodeSettings* getXcodeSettings()
{
	return [SoftSettings sharedPreferences];
}

XcodeThemeManager* getXcodeThemeManager()
{
	return [SoftTheme2 preferenceSetsManager];
}

id hackReturnNil()
{
	return nil;
}

NSMenu* (^contextMenuHook)()=NULL;
NSMenu* hackContextMenu()
{
	return contextMenuHook();
}

void linkXcode()
{
	NSString* dylibPath=replaceXcodePath(@"%/Contents/PlugIns/IDESourceEditor.framework/Versions/A/IDESourceEditor");
	if(!dlopen(dylibPath.UTF8String,RTLD_LAZY))
	{
		alertAbort([NSString stringWithFormat:@"dlopen failed %s",dlerror()]);
	}
	
	SoftInitialize=dlsym(RTLD_DEFAULT,"IDEInitialize");
	SoftDocument=NSClassFromString(@"_TtC15IDESourceEditor18SourceCodeDocument");
	SoftViewController=NSClassFromString(@"_TtC15IDESourceEditor16SourceCodeEditor");
	SoftTheme=NSClassFromString(@"DVTTheme");
	SoftTheme2=NSClassFromString(@"DVTFontAndColorTheme");
	SoftSettings=NSClassFromString(@"DVTTextPreferences");
	SoftSettings2=NSClassFromString(@"IDEFileTextSettings");
	SoftDocumentLocation=NSClassFromString(@"DVTTextDocumentLocation");
	if(!(SoftInitialize&&SoftDocument&&SoftViewController&&SoftTheme&&SoftTheme2&&SoftSettings&&SoftSettings2&&SoftDocumentLocation))
	{
		alertAbort(@"symbol missing");
	}
	
	// TODO: stupid
	
	swizzle(@"IDEDocumentController",@"sharedDocumentController",false,(IMP)hackReturnNil,NULL);
	
	NSError* error=nil;
	SoftInitialize(2,&error);
	if(error)
	{
		alertAbort(@"xcode init failed");
	}
	
	[SoftTheme initialize];
	
	// TODO: even stupider
	
	swizzle(@"_TtC12SourceEditor16SourceEditorView",@"menuForEvent:",true,(IMP)hackContextMenu,NULL);
}

void restartIfNeeded(char** argv)
{
	// TODO: case where it's already set?
	
	if(!getenv("DYLD_FRAMEWORK_PATH"))
	{
		NSString* dylibPaths=replaceXcodePath(@"%/Contents/Frameworks:%/Contents/SharedFrameworks:%/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks:%/Contents/Developer/Library/Frameworks");
		setenv("DYLD_FRAMEWORK_PATH",dylibPaths.UTF8String,true);
		setenv("DYLD_LIBRARY_PATH",dylibPaths.UTF8String,true);
		execv(argv[0],argv);
		
		alertAbort(@"re-exec failed");
	}
}
