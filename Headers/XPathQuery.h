//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>
#import "SoapFunction.h"

@class XPathNodeAttribute;

@interface XPathNode : NSObject
{
	NSString* m_name;
	NSMutableString* m_content;
	NSMutableArray* m_attributes;
	NSMutableArray* m_children;
}

+ (void)initialize;

+ (void) closeXmlLib;

+ (NSArray*)performXPathQueryOnDocPtr:(void*)xmlDocPtr Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;

// Array-returning versions
+ (NSArray*)performHTMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI;

+ (NSArray*)performXMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI;

// Handler versions
+ (void)performHTMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;

+ (void)performXMLXPathQueryOnDocument:(NSData *)document Query:(NSString *)query Prefix:(NSString *)prefix Namespace:(NSString *)namespaceURI XPathNodeHandler:(id <XPathNodeHandler>)handler;


+ (XPathNode*) CreateFromXmlNodePtr:(void*)pXmlNodePtr Parent:(XPathNode*)parent;

+ (NSDictionary*)nodeArrayToDictionary:(NSArray*)nodes;

- (id)init;

- (void)dealloc;

@property (retain, readonly) NSString* name;
@property (retain, readonly) NSString* content;
@property (retain, readonly) NSArray* attributes;
@property (retain, readonly) NSArray* children;

@end

@interface XPathAttr : NSObject
{
	NSString* m_name;
	XPathNode* m_content;
}

- (id)initWithName:(NSString*)name Content:(XPathNode*)node;

- (void)dealloc;

@property (retain, readonly) NSString* name;
@property (retain, readonly) XPathNode* content;

@end
