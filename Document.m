@implementation Document

-(void)makeWindowControllers
{
	NSURL* tempURL=getTempURL();
	if(self.fileURL)
	{
		if(![NSFileManager.defaultManager copyItemAtURL:self.fileURL toURL:tempURL error:nil])
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
	
	self.xcodeDocument=getXcodeDocument(tempURL,self.fileType);
	self.undoManager=self.xcodeDocument.undoManager;
	
	WindowController* controller=[WindowController.alloc initWithDocument:self].autorelease;
	[self addWindowController:controller];
}

-(BOOL)readFromURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error
{
	return true;
}

-(BOOL)writeSafelyToURL:(NSURL*)url ofType:(NSString*)type forSaveOperation:(NSSaveOperationType)operation error:(NSError**)error
{
	BOOL result=[self.xcodeDocument writeSafelyToURL:url ofType:type forSaveOperation:NSSaveToOperation error:error];
	
	// TODO: stupid
	
	if(!self.fileURL)
	{
		dispatch_async(dispatch_get_main_queue(),^()
		{
			self.close;
			[NSDocumentController.sharedDocumentController openDocumentWithContentsOfURL:url display:true completionHandler:^(NSDocument* document,BOOL alreadyOpen,NSError* error)
			{
			}];
		});
	}
	
	return result;
}

-(void)amySave:(id)sender
{
	[self saveDocument:nil];
}

-(void)dealloc
{
	self.xcodeDocument=nil;
	super.dealloc;
}

@end
