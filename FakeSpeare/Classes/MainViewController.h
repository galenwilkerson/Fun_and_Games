//
//  MainViewController.h
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "FakeSpeare.h"
//#import "TextParser.h"

#import <AVFoundation/AVFoundation.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {

	// for playing sound on startup
	IBOutlet AVAudioPlayer *typingPlayer;
	
//	TextParser *textParser1; // object to do input text parsing

	FakeSpeare *fakeSpeare1; //object to do output text processing (play writing)
	
	IBOutlet UITextView *textView1;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	
//	UIButton *calcProbButton;
	IBOutlet UIButton *composeButton;
}

@property (retain, nonatomic) UIButton *composeButton;


//-(IBAction) calcProbButtonPressed;
-(IBAction) composeButtonPressed;
-(IBAction) showInfo;
//-(IBAction) textViewDoneEditing:(id) sender;

@end
