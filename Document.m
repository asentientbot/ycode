@implementation Document

+(void)closeTransientIfNeeded
{
	NSArray<Document*>* documents=NSDocumentController.sharedDocumentController.documents;
	if(documents.count!=1)
	{
		return;
	}
	
	if(documents.firstObject.fileURL||documents.firstObject.documentEdited)
	{
		return;
	}
	
	documents.firstObject.close;
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

-(void)syncWindowController
{
	WindowController* controller=self.windowControllers.lastObject;
	
	if(!controller)
	{
		controller=WindowController.alloc.init.autorelease;
		[self addWindowController:controller];
	}
	
	[controller replaceDocument:self];
}

-(NSString*)actualFileType
{
	if(self.fileURL)
	{
		return [NSDocumentController.sharedDocumentController typeForContentsOfURL:self.fileURL error:nil];
	}
	
	return self.fileType;
}

-(BOOL)loadURL:(NSURL*)url
{
	self.fileURL=url;
	
	NSString* tempName=[NSString stringWithFormat:@"%@.%ld.txt",AppName,(long)(NSDate.date.timeIntervalSince1970*NSEC_PER_SEC)];
	NSURL* tempURL=[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempName]];
	
	if(url)
	{
		if(![NSFileManager.defaultManager copyItemAtURL:url toURL:tempURL error:nil])
		{
			return false;
		}
	}
	else
	{
		if(![NSFileManager.defaultManager createFileAtPath:tempURL.path contents:nil attributes:nil])
		{
			return false;
		}
	}
	
	self.xcodeDocument=[Xcode documentWithURL:tempURL type:[Settings xcodeTypeWithType:self.actualFileType]];
	
	self.syncWindowController;
	
	return true;
}

-(instancetype)initCommonWithURL:(NSURL*)url type:(NSString*)type error:(NSError**)error
{
	self=super.init;
	self.fileType=type;
	
	if(error)
	{
		*error=nil;
	}
	
	if(url)
	{
		Document.closeTransientIfNeeded;
	}
	
	if(![self loadURL:url])
	{
		return nil;
	}
	
	return self;
}

-(instancetype)initWithType:(NSString*)type error:(NSError**)error
{
	return [self initCommonWithURL:nil type:type error:error];
}

-(instancetype)initWithContentsOfURL:(NSURL*)url ofType:(NSString*)type error:(NSError**)error
{
	return [self initCommonWithURL:url type:type error:error];
}

-(instancetype)initForURL:(NSURL*)saveURL withContentsOfURL:(NSURL*)contentsURL ofType:(NSString*)type error:(NSError**)error;
{
	return [self initCommonWithURL:saveURL type:type error:error];
}

-(BOOL)writeSafelyToURL:(NSURL*)url ofType:(NSString*)type forSaveOperation:(NSSaveOperationType)operation error:(NSError**)error
{
	NSNumber* permissions=[NSFileManager.defaultManager attributesOfItemAtPath:url.path error:nil][NSFilePosixPermissions];
	
	if(![self.xcodeDocument writeSafelyToURL:url ofType:type forSaveOperation:NSSaveToOperation error:error])
	{
		return false;
	}
	
	if(permissions)
	{
		[NSFileManager.defaultManager setAttributes:@{NSFilePosixPermissions:permissions} ofItemAtPath:url.path error:nil];
	}
	
	if(!self.fileURL)
	{
		return [self loadURL:url];
	}
	
	return true;
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
