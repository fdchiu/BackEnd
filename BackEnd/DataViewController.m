//
//  DataViewController.m
//  BackEnd
//
//  Created by David on 5/30/15.
//  Copyright (c) 2015 David Chiu. All rights reserved.
//

#import "DataViewController.h"
#import "NetworkSession.h"

@interface DataViewController ()

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    //    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:recognizer1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //self.networkSession.delegate = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) tapped:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (IBAction)send:(id)sender {
    NSInteger tag=[sender tag];
    if (tag==0) {
        [self.networkSession sendNumber:[self.numberTextField text]];
    }
    [self.networkSession sendText:[self.textTextField text]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.statusLabel setText:@""];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(![textField text]) {
        [self.statusLabel setText:@"Number or text field cannot be empty."];
        return;
    }
    
    NSInteger tag=[textField tag];
    
    
}

-(void)dataSend
{
    [self.statusLabel setText:@"Data sent successfully"];
    
}


- (IBAction)closeSession:(id)sender {
    [self.networkSession sessionClose];
}

-(void)sessionEnded
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
