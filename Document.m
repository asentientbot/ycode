@implementation Document

+(void)closeTransientIfNeeded
{
	NSArray<Document*>* documents=NSDocumentController.sharedDocumentController.documents;
	if(documents.count!=2)
	{
		return;
	}
	
	for(Document* document in documents)
	{
		if(document.fileURL||document.documentEdited)
		{
			continue;
		}
		
		[document.windowControllers.firstObject.window performClose:nil];
	}
}

-(void)makeWindowControllers
{
	if(self.fileURL)
	{
		Document.closeTransientIfNeeded;
	}
	
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
		
		NSString* newType=[NSDocumentController.sharedDocumentController typeForContentsOfURL:url error:nil];
		[self loadWithURL:url type:newType];
	}
	
	return result;
}

-(void)amySave:(NSMenuItem*)sender
{
	[self saveDocument:nil];
}

-(void)encodeRestorableStateWithCoder:(NSCoder*)coder
{
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeBool:Delegate.shared.projectMode forKey:@"projectMode"];
}

-(void)restoreStateWithCoder:(NSCoder*)coder
{
	[super restoreStateWithCoder:coder];
	
	BOOL mode=[coder decodeBoolForKey:@"projectMode"];
	if(mode!=Delegate.shared.projectMode)
	{
		Delegate.shared.projectMode=mode;
		dispatch_async(dispatch_get_main_queue(),^()
		{
			WindowController.syncProjectMode;
		});
	}
}

-(void)dealloc
{
	self.xcodeDocument=nil;
	super.dealloc;
}

@end
