//
//  NetworkSession.m
//  BackEnd
//
//  Created by David on 5/28/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import "NetworkSession.h"

@interface NetworkSession()
{
    NSURLConnection *sessionConnection;
    NSString *sessionToken;
    NSString *sessionContentType;
    NSData *sessionData;
    NSInteger sessionID;
    NSString *serverSessionID;
}

@property (strong,atomic) NSMutableArray *taskQueue;

@end

@implementation NetworkSession
-(instancetype)init {
    self = [super init];
    if (self) {
        _taskQueue = [[NSMutableArray alloc] init];
        sessionID = 0;
        _sessionURL = @"http://54.186.152.100/api/candidatesession";
        _dataURL = @"http://54.186.152.100/api/candidatestore";
        sessionToken = @"81495D77-0CA7-4D55-BDFF-D590DE322775";
        sessionContentType = @"application/json";
    }
    return self;
}

#pragma mark - task queue
-(NSMutableDictionary*)findTaskForConnection:(id)connection
{
    for(NSMutableDictionary *dic in self.taskQueue)
        if([dic objectForKey:@"connection"] == connection)
            return dic;
    return nil;
}

-(void)sessionStart
{
    // Create the request.
   // NSURL *URL = [NSURL URLWithString:self.sessionURL];
    NSString *myRequestString =@"{\"api\":\"beginSession\"}";
    //NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
    NSData *myRequestData = [myRequestString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendRequestToURL:self.sessionURL data:myRequestData type:@"sessionBegin" method:@"POST"];
    
   /* NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
    
    [request setValue:[NSString stringWithFormat:@"%@",sessionToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:sessionContentType forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];

    // Create url connection and fire request
     NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:@{@"connection":conn,@"data":[NSNull null],@"sessionID":[NSNumber numberWithInteger:sessionID],@"type":@"session"}];
    sessionID++;
    [self.taskQueue addObject:dic];
    */

}

-(void)sessionClose
{
    NSString *myRequestString =[NSString stringWithFormat:@"{\"sessionId\":%@,\"api\":\"endSession\"}",serverSessionID];
    //NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
    NSData *myRequestData = [myRequestString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendRequestToURL:self.sessionURL data:myRequestData type:@"sessionClose" method:@"POST"];
    
}

-(void)sendRequestToURL:(NSString*)urlString data:(NSData*)data type:(NSString*)type method:(NSString*)method
{
    NSURL *URL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
    
    [request setValue:[NSString stringWithFormat:@"%@",sessionToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:sessionContentType forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", [data length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod: method];
    [request setHTTPBody: data];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:@{@"connection":conn,@"data":[NSNull null],@"sessionID":[NSNumber numberWithInteger:sessionID],@"type":type}];
    sessionID++;
    [self.taskQueue addObject:dic];
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    NSMutableDictionary *dic=[self findTaskForConnection:connection];
    NSLog(@"Response for session:%@",response);
    //[self.taskQueue removeObject:dic];
    if(dic) {
        [dic setObject:[[NSMutableData alloc] init] forKey:@"data"];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    
    NSDictionary *task = [self findTaskForConnection:connection];
    if(task)
        [[task valueForKey:@"data"] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSDictionary *task=[self findTaskForConnection:connection];
    
    if(task) {
        [self parseResponseForTask:task];
        [self.taskQueue removeObject:task];
        //[self handleNext:task];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Error: %@",error);
    NSDictionary *task=[self findTaskForConnection:connection];
    if(task)
        [self.taskQueue removeObject:task];
   // if(task)
   //     [self handleNext:task];
}

-(void)parseResponseForTask:(NSDictionary*)task
{
    NSData *data=[task valueForKey:@"data"];
    
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", newStr);
    NSError *localError;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    if([[task valueForKey:@"type"] isEqualToString:@"sessionBegin"]) {
        serverSessionID = [parsedObject valueForKey:@"sessionId"];
    }
    
    if(self.delegate) {
        if([[task valueForKey:@"type"] isEqualToString:@"sessionBegin"]) {
            if([self.delegate respondsToSelector:@selector(sessionStarted)])
                [self.delegate sessionStarted];
        }
        else {
            if([[task valueForKey:@"type"] isEqualToString:@"sessionClose"]) {
                serverSessionID = nil;
                if([self.delegate respondsToSelector:@selector(sessionEnded)])
                    [self.delegate sessionEnded];
        }
        else
            if([self.delegate respondsToSelector:@selector(dataSend)])
                [self.delegate dataSend];
        }
    }
}

-(void)sendNumber:(NSString*)number
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        
    [dic setObject:@"sendNumber" forKey:@"api"];
    [dic setObject:serverSessionID forKey:@"sessionId"];
    [dic setObject:[NSNumber numberWithInteger:[number intValue]] forKey:@"number"];
    [self sendData:dic];
}

-(void)sendText:(NSString*)text
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@"sendText" forKey:@"api"];
    [dic setObject:serverSessionID forKey:@"sessionId"];
    [dic setObject:text forKey:@"text"];
    [self sendData:dic];
}


-(void)sendData:(id)input
{
    NSError *error;
    NSData *myRequestData = [NSJSONSerialization dataWithJSONObject:input
                                                            options:0 error:&error];
    [self sendRequestToURL:self.dataURL data:myRequestData type:@"data" method:@"POST"];
        // Create the request.
    /*    NSURL *URL = [NSURL URLWithString:self.dataURL];

    NSError *error;
    NSData *myRequestData = [NSJSONSerialization dataWithJSONObject:input
                                    options:0 error:&error];
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
        
        [request setValue:[NSString stringWithFormat:@"%@",sessionToken] forHTTPHeaderField:@"Authorization"];
        [request setValue:sessionContentType forHTTPHeaderField:@"content-type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: myRequestData];
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:@{@"connection":conn,@"data":[NSNull null],@"sessionID":[NSNumber numberWithInteger:sessionID],@"type":@"data"}];
        sessionID++;
        [self.taskQueue addObject:dic];
    */
    

}

@end
