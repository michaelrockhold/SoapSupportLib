//
//  SoapFunction.h
//  BusGnosis
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPathNode;
@protocol XPathNodeHandler

- (void)handleNode:(XPathNode*)node;

@end


@interface SoapFunction : NSObject
{
	NSURL* m_url;
	NSString* m_method;
	NSString* m_namespace;
	NSString* m_soapAction;
	NSDictionary* m_reqHeaders;
	NSArray* m_paramOrder;
	NSString* m_responseQuery;
	NSString* m_responsePrefix;
	NSString* m_responseNamespace;
}

- (id)initWithUrl:(NSString*)url
		   Method:(NSString*)method
	Namespace:(NSString*)ns
	SoapAction:(NSString*)soapAction
	ParamOrder:(NSArray*)paramOrder
	ResponseQuery:(NSString*)responseQuery
	ResponsePrefix:(NSString*)responsePrefix
	ResponseNamespace:(NSString*)responseNamespace;

- (NSArray*)Invoke:(NSDictionary*)params error:(NSError**)error;
- (NSError*)Invoke:(NSDictionary*)params XPathNodeHandler:(id <XPathNodeHandler>)nodeHandler;

@end
