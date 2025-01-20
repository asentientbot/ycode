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
	[self loadWithURL:self.fileURL];
}

-(void)loadWithURL:(NSURL*)url
{
	NSURL* tempURL=getTempURL();
	NSString* type;
	if(url)
	{
		if(![NSFileManager.defaultManager copyItemAtURL:url toURL:tempURL error:nil])
		{
			alertAbort(@"copy error");
		}
		type=[NSDocumentController.sharedDocumentController typeForContentsOfURL:url error:nil];
	}
	else
	{
		if(![NSFileManager.defaultManager createFileAtPath:tempURL.path contents:nil attributes:nil])
		{
			alertAbort(@"touch error");
		}
		type=self.fileType;
	}
	
	self.xcodeDocument.close;
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
	NSNumber* permissions=[NSFileManager.defaultManager attributesOfItemAtPath:url.path error:nil][NSFilePosixPermissions];
	BOOL result=[self.xcodeDocument writeSafelyToURL:url ofType:type forSaveOperation:NSSaveToOperation error:error];
	if(permissions)
	{
		[NSFileManager.defaultManager setAttributes:@{NSFilePosixPermissions:permissions} ofItemAtPath:url.path error:nil];
	}
	
	if(!self.fileURL)
	{
		[self loadWithURL:url];
	}
	
	return result;
}

-(void)handleSave:(NSMenuItem*)sender
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
		dispatch_async(dispatch_get_main_queue(),^()
		{
			Delegate.shared.projectMode=mode;
			WindowController.syncProjectMode;
		});
	}
}

-(void)close
{
	self.xcodeDocument.close;
	
	super.close;
}

-(void)dealloc
{
	self.xcodeDocument=nil;
	
	super.dealloc;
}

@end
