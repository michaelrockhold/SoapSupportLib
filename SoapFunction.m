//
//  SoapFunction.m
//  SOAP_AuthExample
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoapFunction.h"
#import "XPathQuery.h"

@implementation SoapFunction

- (id)initWithUrl:(NSString*)url
		   Method:(NSString*)method
		Namespace:(NSString*)ns
	   SoapAction:(NSString*)soapAction
	   ParamOrder:(NSArray*)paramOrder
	ResponseQuery:(NSString*)responseQuery
   ResponsePrefix:(NSString*)responsePrefix
ResponseNamespace:(NSString*)responseNamespace
{
	id this = [super init];
	if ( this != nil )
	{
		m_url = [[NSURL URLWithString:url] retain];
		m_method = [method retain];
		m_namespace = [ns retain];
		m_soapAction = [soapAction retain];
		m_reqHeaders = [[NSDictionary dictionaryWithObject:soapAction forKey:@"SOAPAction"] retain];
		m_paramOrder = [paramOrder retain];
		m_responseQuery = responseQuery;
		if (m_responseQuery) [m_responseQuery retain];
		m_responsePrefix = responsePrefix;
		if (m_responsePrefix) [m_responsePrefix retain];
		m_responseNamespace = responseNamespace;
		if (m_responseNamespace) [m_responseNamespace retain];
	}
	return this;
}

- (void)dealloc
{
	[m_url release];
	[m_method release];
	[m_namespace release];
	[m_soapAction release];
	[m_paramOrder release];
	[m_reqHeaders release];
	[m_responseQuery release];
	[m_responsePrefix release];
	[m_responseNamespace release];
	[super dealloc];
}

- (NSError*)Invoke:(NSDictionary*)params XPathNodeHandler:(id <XPathNodeHandler>)nodeHandler
{
	NSError* error = nil;
	NSMutableString* soapMessage = [NSMutableString stringWithFormat:
									@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
									<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
									<soap:Body>\
									<%@ xmlns=\"%@\">",
									m_method,
									m_namespace];
	
	for (NSString* param in m_paramOrder)
	{
		[soapMessage appendString:[NSString stringWithFormat:
								   @"<%@>%@</%@>",
								   param,
								   [params valueForKey:param],
								   param
								   ]];
	}
	
	[soapMessage appendString:[NSString stringWithFormat:
							   @"</%@>\
							   </soap:Body>\
							   </soap:Envelope>",
							   m_method
							   ]];
	
	NSData* msgData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:m_url];
	[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:m_soapAction forHTTPHeaderField:@"SOAPAction"];
	[request addValue:[NSString stringWithFormat:@"%lu", [msgData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:msgData];
	
	NSHTTPURLResponse* response;
	NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error != nil )
	{
		return error;
	}
	else if ( response != nil && [response statusCode] == 200 && responseData != nil )
	{
		[XPathNode performXMLXPathQueryOnDocument:responseData Query:m_responseQuery Prefix:m_responsePrefix Namespace:m_responseNamespace XPathNodeHandler:nodeHandler];
		return nil;
	}
	else // ?? error object was not returned, and yet all is not as it should be
	{
		return [NSError errorWithDomain:@"com.rockholdco.SoapFunction" code:1 userInfo:nil];
	}
}

- (NSArray*)Invoke:(NSDictionary *)params error:(NSError**)perror
{
	NSMutableString* soapMessage = [NSMutableString stringWithFormat:
									@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
									<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
									<soap:Body>\
									<%@ xmlns=\"%@\">",
									m_method,
									m_namespace];
	
	for (NSString* param in m_paramOrder)
	{
		[soapMessage appendString:[NSString stringWithFormat:
								   @"<%@>%@</%@>",
								   param,
								   [params valueForKey:param],
								   param
								   ]];
	}
	
	[soapMessage appendString:[NSString stringWithFormat:
							   @"</%@>\
							   </soap:Body>\
							   </soap:Envelope>",
							   m_method
							   ]];
	
	NSData* msgData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:m_url];
	[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:m_soapAction forHTTPHeaderField:@"SOAPAction"];
	[request addValue:[NSString stringWithFormat:@"%lu", [msgData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:msgData];
	
	NSHTTPURLResponse* response;
	NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:perror];
	
	if ( *perror == nil && response != nil && [response statusCode] == 200 && responseData != nil )
	{
		return [XPathNode performXMLXPathQueryOnDocument:responseData Query:m_responseQuery Prefix:m_responsePrefix Namespace:m_responseNamespace];
	}
	else
	{
		if (*perror != nil)
		{
			NSLog(@"error: %@\n", *perror);
		}
		else
		{
			*perror = [NSError errorWithDomain:@"com.rockholdco.SoapFunction" code:1 userInfo:nil];
			NSLog(@"unknown error in SoapFunction Invoke:error:\n");
		}
		return nil;
	}
}

/* Example response from a bad invocation:
 <?xml version="1.0" encoding="utf-8"?>
 <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <soap:Body>
 <soap:Fault>
 <faultcode>soap:Server.userException</faultcode>
 <faultstring>java.lang.IllegalArgumentException: bad request: its.app.mybus.store2.ser.LocationRequest@22e4bc</faultstring> 
 <detail />
 </soap:Fault>
 </soap:Body>
 </soap:Envelope>
 */

/*
 <?xml version="1.0" encoding="utf-8"?>
 <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <soap:Body>
 <getEventEstimatesIResponse xmlns="http://dotnet.ws.its.washington.edu"><getEventEstimatesIResult /></getEventEstimatesIResponse>
 </soap:Body>
 </soap:Envelope>
 */

@end
