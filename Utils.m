NSString* getAppName()
{
	return NSProcessInfo.processInfo.arguments[0].lastPathComponent;
}

NSURL* getTempURL()
{
	NSString* name=[NSString stringWithFormat:@"%@.%ld.txt",getAppName(),(long)(NSDate.date.timeIntervalSince1970*NSEC_PER_SEC)];
	return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

void alert(NSString* message)
{
	NSAlert* alert=NSAlert.alloc.init.autorelease;
	alert.messageText=getAppName();
	alert.informativeText=message;
	alert.runModal;
}

__attribute__((noreturn)) void alertAbort(NSString* message)
{
	alert([NSString stringWithFormat:@"fatal: %@",message]);
	
	abort();
}

void swizzle(NSString* className,NSString* selName,BOOL isInstance,IMP newImp,IMP* oldImpOut)
{
	Class class=NSClassFromString(className);
	if(!class)
	{
		alertAbort(@"swizzle class missing");
	}
	
	SEL sel=NSSelectorFromString(selName);
	Method method=isInstance?class_getInstanceMethod(class,sel):class_getClassMethod(class,sel);
	if(!method)
	{
		alertAbort(@"swizzle method missing");
	}
	
	IMP oldImp=method_setImplementation(method,newImp);
	if(oldImpOut)
	{
		*oldImpOut=oldImp;
	}
}
