@implementation Document

-(void)makeWindowControllers
{
	[self addWindowController:WindowController.alloc.init.autorelease];
	[self loadWithURL:self.fileURL type:self.fileType];
}

-(void)loadWithURL:(NSURL*)url type:(NSString*)type
{
	NSURL* tempURL=getTempURL();
	if(url)
	{
		if(![NSFileManager.defaultManager copyItemAtURL:url toURL:tempURL error:nil])
		{
			alertAbort(@"copy error");
		}
	}
	else
	{
		if(![NSFileManager.defaultManager createFileAtPath:tempURL.path contents:nil attributes:nil])
		{
			alertAbort(@"touch error");
		}
	}
	
	self.xcodeDocument=getXcodeDocument(tempURL,type);
	self.undoManager=self.xcodeDocument.undoManager;
	
	[(WindowController*)self.windowControllers.lastObject replaceDocument:self];
}

-(BOOL)readFromURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error
{
	return true;
}

-(BOOL)writeSafelyToURL:(NSURL*)url ofType:(NSString*)type forSaveOperation:(NSSaveOperationType)operation error:(NSError**)error
{
	BOOL result=[self.xcodeDocument writeSafelyToURL:url ofType:type forSaveOperation:NSSaveToOperation error:error];
	
	if(!self.fileURL)
	{
		// TODO: a tiny bit weird. maybe we can skip this by moving a bit "later" in the save process.
		// also, we should be able to do TextEdit-style "transient" untitled documents now
		
		NSString* newType=[NSDocumentController.sharedDocumentController typeForContentsOfURL:url error:nil];
		[self loadWithURL:url type:newType];
	}
	
	return result;
}

-(void)amySave:(NSMenuItem*)sender
{
	[self saveDocument:nil];
}

-(void)dealloc
{
	self.xcodeDocument=nil;
	super.dealloc;
}

@end
