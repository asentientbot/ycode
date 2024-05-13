__attribute__((noreturn)) void alertAbort(NSString* message)
{
	NSAlert* alert=NSAlert.alloc.init.autorelease;
	alert.messageText=@"fatal";
	alert.informativeText=message;
	alert.runModal;
	
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

struct mach_header_64* imageHeaderForPointer(char* pointer)
{
	Dl_info info={};
	if(!dladdr(pointer,&info))
	{
		alertAbort(@"dladdr failed");
	}
	return info.dli_fbase;
}

char* findPrivateSymbol(struct mach_header_64* header,char* symbol)
{
	struct load_command* command=(struct load_command*)(header+1);
	long linkeditDelta=0;
	for(int index=0;index<header->ncmds;index++)
	{
		if(command->cmd==LC_SYMTAB)
		{
			if(!linkeditDelta)
			{
				alertAbort(@"linkedit delta missing");
			}
			
			struct symtab_command* symtab=(struct symtab_command*)command;
			char* strings=(char*)header+linkeditDelta+symtab->stroff;
			struct nlist_64* symbols=(struct nlist_64*)((char*)header+linkeditDelta+symtab->symoff);
			for(int index=0;index<symtab->nsyms;index++)
			{
				if(!strcmp(strings+symbols[index].n_un.n_strx,symbol))
				{
					return (char*)header+symbols[index].n_value;
				}
			}
		}
		
		if(command->cmd==LC_SEGMENT_64)
		{
			struct segment_command_64* segment=(struct segment_command_64*)command;
			if(!strcmp(segment->segname,SEG_LINKEDIT))
			{
				linkeditDelta=segment->vmaddr-segment->fileoff;
			}
		}
		
		command=(struct load_command*)((char*)command+command->cmdsize);
	}
	
	alertAbort(@"private symbol missing");
}

void patchAt(char* address,char* bytes,int length)
{
	if(mprotect((void*)((long)address&~0xfff),0x2000,PROT_WRITE|PROT_EXEC))
	{
		alertAbort(@"mprotect failed");
	}
	memcpy(address,bytes,length);
}
