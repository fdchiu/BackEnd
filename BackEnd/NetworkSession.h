//
//  NetworkSession.h
//  BackEnd
//
//  Created by David on 5/28/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkSessionDelegate <NSObject>

@optional
-(void)sessionStarted;
-(void)dataSend;
-(void)sessionEnded;

@end

@interface NetworkSession : NSObject

@property (nonatomic,strong) NSString *sessionURL;
@property (nonatomic,strong) NSString *dataURL;
@property (nonatomic,weak) id<NetworkSessionDelegate> delegate;

-(void)sessionStart;
-(void)sessionClose;
-(void)sendNumber:(NSString*)number;
-(void)sendText:(NSString*)text;
@end
