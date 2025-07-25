@implementation SettingsMapping

+(instancetype)mappingWithName:(NSString*)name getter:(NSString*)getterName setter:(NSString*)setterName defaultValue:(BOOL)defaultValue
{
	SettingsMapping* mapping=SettingsMapping.alloc.init.autorelease;
	
	mapping.name=name;
	mapping.getter=NSSelectorFromString(getterName);
	mapping.setter=NSSelectorFromString(setterName);
	mapping.defaultValue=defaultValue;
	
	return mapping;
}

+(instancetype)mappingWithName:(NSString*)name getter:(NSString*)getterName defaultValue:(BOOL)defaultValue
{
	NSString* firstChar=[getterName substringToIndex:1].uppercaseString;
	NSString* otherChars=[getterName substringFromIndex:1];
	NSString* setterName=[NSString stringWithFormat:@"set%@%@:",firstChar,otherChars];
	
	return [SettingsMapping mappingWithName:name getter:getterName setter:setterName defaultValue:defaultValue];
}

-(BOOL)supported
{
	return [Xcode.settings respondsToSelector:self.getter]&&[Xcode.settings respondsToSelector:self.setter];
}

-(BOOL)value
{
	if(self.supported)
	{
		return (BOOL)(long)[Xcode.settings performSelector:self.getter];
	}
	
	return false;
}

-(void)setValue:(BOOL)value
{
	if(self.supported)
	{
		[Xcode.settings performSelector:self.setter withObject:(id)(long)value];
	}
}

-(void)reset
{
	self.value=self.defaultValue;
}

-(void)toggle
{
	self.value=!self.value;
}

-(void)dealloc
{
	self.name=nil;
	
	super.dealloc;
}

@end
