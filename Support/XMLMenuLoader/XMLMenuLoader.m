/*********************************************************************
 *	
 *	XML Menu Loader
 *
 *	XMLMenuLoader.m
 *
 *	Load game menu in from XML file
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 02/22/2010.
 *	Copyright 2010 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "XMLMenuLoader.h"


@implementation XMLMenuLoader

- (id) initWithMenu:(LevelSelectLayer *)menu
{
	[super init];
	
	_menu = menu;
	
	return self;
}

- (void) parseXMLFileAtURL:(NSString*)file
{	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath: [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:[file stringByAppendingPathExtension:@"xml"]]]];
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
	
	//Getting errors...
	/*NSError *parseError = [parser parserError];
	 if (parseError && error) {
	 *error = parseError;
	 }*/
	
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	//Not sure why this is here...
	if (qName) 
		elementName = qName;
	
	if ([elementName isEqualToString:@"pack"]) 
	{
	
		NSString	*name = [attributeDict valueForKey:@"name"];
		NSString	*image = [attributeDict valueForKey:@"image"];
		[_menu addPackTooth:name Image:image];
	}
	else if ([elementName isEqualToString:@"level"])
	{
		NSString	*name = [attributeDict valueForKey:@"name"];
		NSString	*image = [attributeDict valueForKey:@"image"];
		int			levelId = [[attributeDict valueForKey:@"id"] intValue];
		[_menu addLevelTooth:levelId Name:name Image:image];
	}

}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
		NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}
	

@end