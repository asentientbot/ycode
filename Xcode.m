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

@interface FakeExtension:NSObject
@end

@implementation FakeExtension

-(NSString*)identifier
{
	return @"";
}

@end

XcodeViewController* getXcodeViewController(XcodeDocument* document)
{
	XcodeViewController* controller=[(XcodeViewController*)[SoftViewController alloc] initWithNibName:nil bundle:nil document:document].autorelease;
	
	controller.representedExtension=FakeExtension.alloc.init.autorelease;
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

id returnNil()
{
	return nil;
}

void linkXcode()
{
	if(!dlopen("/Applications/Xcode.app/Contents/PlugIns/IDESourceEditor.framework/Versions/A/IDESourceEditor",RTLD_LAZY))
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
	
	swizzle(@"IDEDocumentController",@"sharedDocumentController",false,(IMP)returnNil,NULL);
	
	NSError* error=nil;
	SoftInitialize(2,&error);
	if(error)
	{
		alertAbort(@"xcode init failed");
	}
	
	// TODO: does SoftTheme2 work for this? (test Chloe)
	
	[SoftTheme initialize];
}

void restartIfNeeded(char** argv)
{
	// TODO: case where it's already set?
	
	if(!getenv("DYLD_FRAMEWORK_PATH"))
	{
		// TODO: define properly (this for HS; fewer strictly needed on Sonoma)
		// TODO: configurable Xcode location?
		
		setenv("DYLD_FRAMEWORK_PATH","/Applications/Xcode.app/Contents/Frameworks:/Applications/Xcode.app/Contents/SharedFrameworks:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks:/Applications/Xcode.app/Contents/Developer/Library/Frameworks",true);
		execv(argv[0],argv);
		
		alertAbort(@"re-exec failed");
	}
}
