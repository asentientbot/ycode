#define trace NSLog

#define stringify2(name) #name
#define stringify(name) stringify2(name)

NSString* AppName=@(stringify(YcodeAppName));
NSString* GitHash=@(stringify(YcodeGitHash));

void alert(NSString* message)
{
	NSAlert* alert=NSAlert.alloc.init.autorelease;
	alert.messageText=AppName;
	alert.informativeText=message;
	alert.runModal;
}

__attribute__((noreturn)) void alertAbort(NSString* message)
{
	alert([NSString stringWithFormat:@"fatal: %@",message]);
    trace(@"%@ %@",message,NSThread.callStackSymbols);
	exit(1);
}
