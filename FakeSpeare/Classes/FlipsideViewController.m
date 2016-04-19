//
//  FlipsideViewController.m
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize lengthSlider;

@synthesize infoView;
@synthesize playLengthLabel;
@synthesize playsWillHaveLabel;
@synthesize actsLabel;
@synthesize copyrightView;
@synthesize lengthLabel;
@synthesize titleView;

- (void)viewDidLoad {
    [super viewDidLoad];
			
	//set the textview's background image
	UIImageView *imgView = [[UIImageView alloc]initWithFrame: self.view.frame];
	//TODO: need retain?
	
	imgView.image = [UIImage imageNamed: @"old-paper.jpg"];

	[self.view addSubview: imgView];
    [self.view sendSubviewToBack: imgView];	
	[imgView release];
	
	[infoView setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	[playLengthLabel setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	[playsWillHaveLabel setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	[actsLabel setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	[copyrightView setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	[lengthLabel setFont: [UIFont fontWithName:@"AmericanTypewriter" size: 18]];
	
	[titleView setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size: 18]];

	
}

/*
- (IBAction)lengthSliderMoved:(id)sender {
	float tempVal;
	tempVal= lengthSlider.value;
	DLog(@"slider = %d",tempVal);
	playLengthLabel.text = [NSString stringWithFormat:@"%@",lengthSlider.value];
}
*/

- (IBAction)done {

	
	[self.delegate flipsideViewControllerDidFinish:self];	
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
}


- (void)dealloc {
		
	//[imgView release];
	/* //TODO: when to release?
	[ lengthSlider release];
	[ playLengthLabel release];
    [ infoView release];
	[ playLengthLabel release];
	[ playsWillHaveLabel release];
	[ actsLabel release];
	[ copyrightView release];
	[ lengthLabel release];
	 */
	//TODO: should this be released?
	//[ titleView release];
	
	[super dealloc];
}


@end
