#define trace NSLog

#define stringify2(name) #name
#define stringify(name) stringify2(name)

CGImageRef createAppIcon(CGColorRef background,CGColorRef stroke,CGColorRef fill)
{
	CGRect rect=CGRectMake(0,0,1024,1024);
	
	CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(NULL,1024,1024,8,1024*4,space,kCGImageAlphaPremultipliedFirst);
	CFRelease(space);
	
	// TODO: doesn't precisely match Apple's template, but neither does NSIconGenericApplication, so..
	
	CALayer* container=CALayer.layer;
	container.frame=rect;
	CALayer* round=CALayer.layer;
	round.frame=CGRectMake(100,100,824,824);
	round.backgroundColor=background;
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
	CGContextSetLineWidth(context,40);
	CGContextSetTextDrawingMode(context,kCGTextFillStroke);
	CGContextSetFillColorWithColor(context,fill);
	CGContextSetStrokeColorWithColor(context,stroke);
	CGContextSelectFont(context,"Futura-Bold",650,kCGEncodingMacRoman);
	CGContextShowTextAtPoint(context,290,410,"y",1);
	
	CGImageRef image=CGBitmapContextCreateImage(context);
	CFRelease(context);
	return image;
}

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
    trace(@"%@ %@",message,NSThread.callStackSymbols);
	exit(1);
}

void swizzle(NSString* className,NSString* selName,BOOL isInstance,IMP newImp,IMP* oldImpOut)
{
	Class class=NSClassFromString(className);
	if(!class)
	{
		alertAbort(@"swizzle class missing");
	}
	
	SEL sel=NSSelectorFromString(selName);
	Method method=(isInstance?class_getInstanceMethod:class_getClassMethod)(class,sel);
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

id returnNil()
{
	return nil;
}

// TODO: hack to compile on older macOS (10.9+ but not in headers..?)

@interface NSView()

-(void)setClipsToBounds:(BOOL)value;

@end
