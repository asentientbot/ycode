@import AppKit;
#define trace NSLog

int main(int argc,char** argv)
{
	CGRect rect=CGRectMake(0,0,1024,1024);
	
	CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(NULL,1024,1024,8,1024*4,space,kCGImageAlphaPremultipliedFirst);
	
	CGImageRef base=[[NSImage imageNamed:@"NSIconGenericApplication"] CGImageForProposedRect:&rect context:nil hints:nil];
	CGContextDrawImage(context,rect,base);
	
	CGContextSetRGBFillColor(context,1,1,1,1);
	CGContextFillRect(context,CGRectMake(155,155,714,714));
	
	CGContextSetLineJoin(context,kCGLineJoinRound);
	CGContextSetLineWidth(context,30);
	CGContextSetTextDrawingMode(context,kCGTextFillStroke);
	CGContextSetRGBFillColor(context,0.95,0.85,1,1);
	CGContextSetRGBStrokeColor(context,0.4,0.3,0.8,1);
	CGContextSelectFont(context,"Futura-Bold",650,kCGEncodingMacRoman);
	CGContextShowTextAtPoint(context,290,410,"y",1);
	
	CGImageRef image=CGBitmapContextCreateImage(context);
	NSURL* url=[NSURL fileURLWithPath:@"icon.png"];
	CGImageDestinationRef destination=CGImageDestinationCreateWithURL((CFURLRef)url,kUTTypePNG,1,NULL);
	CGImageDestinationAddImage(destination,image,NULL);
	CGImageDestinationFinalize(destination);
}
