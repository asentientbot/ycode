void (*SoftInitialize)(int,NSError**);
Class SoftDocument;
Class SoftViewController;
Class SoftTheme;
Class SoftSettings;
Class SoftSettings2;

@interface XcodeDocument:NSDocument

-(instancetype)initWithContentsOfURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error;

@end

@interface XcodeViewController:NSViewController

@property(retain) NSObject* representedExtension;
@property(retain) NSObject* fileTextSettings;

-(instancetype)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle document:(NSDocument*)document;

@end

@interface XcodeSettings:NSObject

+(instancetype)sharedPreferences;

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

NSObject* getXcodeSettings()
{
	return [SoftSettings sharedPreferences];
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
	SoftSettings=NSClassFromString(@"DVTTextPreferences");
	SoftSettings2=NSClassFromString(@"IDEFileTextSettings");
	if(!(SoftInitialize&&SoftDocument&&SoftViewController&&SoftTheme&&SoftSettings&&SoftSettings2))
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
