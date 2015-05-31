//
//  ViewController.h
//  BackEnd
//
//  Created by David on 5/28/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkSession.h"


@interface ViewController : UIViewController <NetworkSessionDelegate>

@property (nonatomic,strong) NetworkSession *networkSession;
- (IBAction)startSession:(id)sender;

@end

