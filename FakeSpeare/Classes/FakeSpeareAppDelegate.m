//
//  FakeSpeareAppDelegate.m
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FakeSpeareAppDelegate.h"
#import "MainViewController.h"

@implementation FakeSpeareAppDelegate


@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// the music player
	//	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/whatif.mp3", [[NSBundle mainBundle] resourcePath]]];
	NSString *musicFilename;

	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	//NSBundle *thisBundle = [NSBundle bundleWifile://localhost/Users/galenwilkerson/Work/Software/iPhone/Projects/Development/FakeSpeare/Classes/FakeSpeareAppDelegate.mthIdentifier:@"Sounds"];
	//NSArray* myBundles = [NSBundle allBundles];
	
	int randNum = arc4random()%2;

	if (randNum == 0) {
		//musicFilename = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Sounds/whatif.wav";
		musicFilename = [thisBundle pathForResource:@"whatif" ofType:@"mp3" ];
	}
	else {
		//musicFilename = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Sounds/witches.wav";
		musicFilename = [thisBundle pathForResource:@"witches" ofType:@"mp3" ];
	}

	NSURL *url = [NSURL fileURLWithPath:musicFilename];

	DLog(@"In applicationDidFinishLaunching");
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = 0; //loop once =0, keep looping = -1 (unless sound switched off)
	audioPlayer.volume = 0.25;
	[audioPlayer play];	
	//sleep(2);
	//NSLog(@"Done sleeping!");
	
	//[url release];
	
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
	[audioPlayer stop];
	[audioPlayer release];
	
    [super dealloc];
}

@end
