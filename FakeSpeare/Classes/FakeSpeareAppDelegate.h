//
//  FakeSpeareAppDelegate.h
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class MainViewController;

@interface FakeSpeareAppDelegate : NSObject <UIApplicationDelegate> {

	IBOutlet AVAudioPlayer *audioPlayer;

    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end

