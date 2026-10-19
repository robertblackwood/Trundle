//
//  PreLevelLoader.m
//  Trundle
//
//  Created by Robert Blackwood on 12/14/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "PreLevelLoader.h"
#import "SimpleAudioEngine.h"


@implementation PreLevelLoader

- (id)initWithGameLayer:(GameLayer*)layer
{
	[super init];
	
	_layer = layer;
	
	return self;
}

- (void)parseXMLFileAtURL:(NSString*)file
{	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath: [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:[file stringByAppendingPathExtension:@"xml"]]]];
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	if (qName) 
		elementName = qName;
	
	if ([elementName isEqualToString:@"screenCount"]) 
	{
		int count = [[attributeDict valueForKey:@"number"] intValue];
		_layer.screenCount = count;
	}
	else if ([elementName isEqualToString:@"music"])
	{
		NSString *file = [attributeDict valueForKey:@"file"];
		
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:file];
	}
}

@end
