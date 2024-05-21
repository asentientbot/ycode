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
	return [getXcodeSettings() respondsToSelector:self.getter]&&[getXcodeSettings() respondsToSelector:self.setter];
}

-(BOOL)getValue
{
	if(self.supported)
	{
		return (BOOL)(long)[getXcodeSettings() performSelector:self.getter];
	}
	return false;
}

-(void)setValue:(BOOL)value
{
	if(self.supported)
	{
		[getXcodeSettings() performSelector:self.setter withObject:(id)(long)value];
	}
}

-(void)reset
{
	if(self.supported)
	{
		[self setValue:self.defaultValue];
	}
}

@end
