@implementation Document

+(void)closeTransientIfNeeded
{
	// TODO: still weird
	
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

-(void)setXcodeDocument:(XcodeDocument*)newDocument
{
	if(_xcodeDocument)
	{
		self.undoManager=nil;
		
		[Xcode destroyDocument:_xcodeDocument];
		
		_xcodeDocument.release;
	}
	
	_xcodeDocument=newDocument.retain;
	
	self.undoManager=_xcodeDocument.undoManager;
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
	NSString* tempName=[NSString stringWithFormat:@"%@.%ld.txt",AppName,(long)(NSDate.date.timeIntervalSince1970*NSEC_PER_SEC)];
	NSURL* tempURL=[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempName]];
	
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
	
	self.xcodeDocument=[Xcode documentWithURL:tempURL type:type];
	
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
	
	Delegate.shared.projectMode=[coder decodeBoolForKey:@"projectMode"];
}

-(void)dealloc
{
	self.xcodeDocument=nil;
	
	super.dealloc;
}

@end
