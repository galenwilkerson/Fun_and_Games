//
//  MainViewController.m
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

#import "MainViewController.h"
#import "MainView.h"


//TODO: add documentation

@implementation MainViewController

@synthesize composeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
		//how to get this object to persist after this function call? Need to release?
		// Answer:  This is a data member of the current object (self), so it will be released when self is released//
		//textParser1 = [[TextParser alloc] init];

		
		fakeSpeare1 = [[FakeSpeare alloc] init];
		
		//TODO: why is the composebutton null?  seems correct.  Didn't have to init buttons on flipside...?
		//composeButton = [[UIButton alloc] init];
		//		composeButton.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size: 12];
		//	[composeButton.titleLabel setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];

		// the sound player
		NSString *typingFilename;
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
		typingFilename = [thisBundle pathForResource:@"typing_fast" ofType:@"mp3" ];
		NSURL *url = [NSURL fileURLWithPath:typingFilename];
		
		DLog(@"In awakeFromNib");
		NSError *error;
		typingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		
    }
	DLog(@"Done initWithNibName");

    return self;
}

// called when the calc prob button is pressed in the UI
/*
 -(IBAction) calcProbButtonPressed {
	
	//calculate the word-pair probabilities	
//	[textParser1 calculateWordPairProbabilities];
//	 [textParser1 calculateTitleProbabilities];
 
}
*/

//called when the compose button is pressed in the UI
//TODO: disable button while composing
-(IBAction) composeButtonPressed {
	DLog(@"start composeButtonPressed");

	//TODO: this doesn't seem to work
	composeButton.enabled = FALSE;
	
	//TODO: seems to work, is this good use of a thread?
	[activityIndicator performSelectorInBackground:@selector(startAnimating) withObject: nil];
	
	typingPlayer.numberOfLoops = -1;
	[typingPlayer play];	
	
	//TODO:  have to release the old text?
	textView1.text = [fakeSpeare1 composeText];
	
	[textView1 scrollRangeToVisible:NSMakeRange(0, 1) ];
	//NSMakeRange(NSNotFound, 0)
	
	[activityIndicator performSelector: @selector(stopAnimating)]; //stop the wheel
	[typingPlayer stop];
	DLog(@"Done composeButtonPressed");
	composeButton.enabled = TRUE;

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	

	//stop the wheel, it should disappear
	[activityIndicator stopAnimating]; //stop the wheel
	
	// do this instead in object's init method [fakeSpeare1 setPlayLength: DEFAULT_PLAY_LENGTH];
	
	
	
	// set the fonts
	[titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size: 36]];
	//[titleLabel setFont:[UIFont fontWithName:@"Georgia" size: 36]];

//	[textView1 setFont: [UIFont fontWithName:@"AmericanTypewriter-Bold" size: 15]];
	[textView1 setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	
	
	//set the textview's background image
	UIImageView *imgView = [[UIImageView alloc]initWithFrame: self.view.frame];
	imgView.image = [UIImage imageNamed: @"old-paper.jpg"];
    [self.view addSubview: imgView];
    [self.view sendSubviewToBack: imgView];	
	
	//TODO: check if probability file is there, if not, throw error/exception
	//TODO: run on startup:
	//TODO: shorter play on startup 
	//textView1.text = [fakeSpeare1 composeText];
	[imgView release];
    [super viewDidLoad];
	DLog(@"Done viewDidLoad");
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	//TODO:  play the sound of a page turning
	// maybe use separate thread

	
	
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (IBAction) textViewDoneEditing:(id) sender {

	[sender resignFirstResponder];
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[typingPlayer stop];

}


- (void)dealloc {
	
	//TODO: did I release everything?
	
	[fakeSpeare1 release];
	[composeButton release];
	
	[typingPlayer stop];
	[typingPlayer release];
	
	[textView1 release];
	//[calcProbButton release];
	[composeButton release];
	[activityIndicator release];
    [super dealloc];
}


@end
