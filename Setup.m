void (*SoftInitialize)(int,NSError**);
Class SoftDocument;
Class SoftViewController;

@interface XcodeDocument:NSDocument

-(instancetype)initWithContentsOfURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error;

@end

@interface XcodeViewController:NSViewController

-(instancetype)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle document:(NSDocument*)document;
-(void)setRepresentedExtension:(NSObject*)extension;

@end

id returnNil()
{
	return nil;
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

void setDefaults()
{
	// TODO: some configurable in menubar. import from Xcode option?
	
	NSDictionary<NSString*,id>* settings=@{@"DVTTextAutoCloseBlockComment":@false,@"DVTTextEnableTypeOverCompletions":@false,@"DVTTextAutoInsertCloseBrace":@false,@"DVTTextAutoInsertOpenBracket":@false,@"DVTTextAutoSuggestCompletions":@false,@"DVTTextIndentUsingTabs":@true,@"DVTTextUsesSyntaxAwareIndenting":@false,@"DVTTextWrappedLinesIndentWidth":@0,@"DVTTextOverscrollAmount":@0.5,@"DVTTextAutoEncloseSelectionInDelimiters":@false};
	for(NSString* key in settings.allKeys)
	{
		[NSUserDefaults.standardUserDefaults setValue:settings[key] forKey:key];
	}
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
	if(!SoftInitialize||!SoftDocument||!SoftViewController)
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
}

void lineWrapHack()
{
	// TODO: cursed, breaks older Xcode support, breaks arm support, not configurable..
	
	struct mach_header_64* header=imageHeaderForPointer((char*)NSClassFromString(@"SourceEditorScrollView"));
	
	char* breakCode=findPrivateSymbol(header,"_$s12SourceEditor12LineWrappingC14indexToBreakOn6string10startIndex5range08maxCharshC0SiSo11CFStringRefa_SiSo8_NSRangeVSitFZTf4nnnnd_n");
	patchAt(breakCode,"\x4C\x89\xC0\xC3",4);
	
	// TODO: minimap unaffected
	
	char* insetCode=findPrivateSymbol(header,"_$s12SourceEditor18CoreTextLineLayoutC9wrapInset33_E899FBC4D0CBDBB8D5F3BB86604266C3LL0C8Graphics7CGFloatVvg");
	patchAt(insetCode,"\x0F\x57\xC0\xC3",4);
}

void startup(int argc,char** argv)
{
	restartIfNeeded(argv);
	setDefaults();
	linkXcode();
	lineWrapHack();
}
