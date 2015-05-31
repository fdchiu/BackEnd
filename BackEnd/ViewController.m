//
//  ViewController.m
//  BackEnd
//
//  Created by David on 5/28/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import "ViewController.h"
#import "DataViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.networkSession = [[NetworkSession alloc] init];
    [self.networkSession setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.networkSession.delegate = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startSession:(id)sender {
    
    [self.networkSession sessionStart];
}


-(void)sessionStarted
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *vC=[storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    [(DataViewController*)vC setNetworkSession:self.networkSession];
    [self.networkSession setDelegate:(DataViewController*)vC];
    [self presentViewController:vC animated:YES completion:nil];
}

-(void)dataSend
{
    NSLog(@"Data send");
}

@end
