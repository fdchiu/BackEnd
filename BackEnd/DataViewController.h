//
//  DataViewController.h
//  BackEnd
//
//  Created by David on 5/30/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkSession.h"

@interface DataViewController : UIViewController <NetworkSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *textTextField;
@property (weak, nonatomic) NetworkSession* networkSession;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


- (IBAction)closeSession:(id)sender;

@end
