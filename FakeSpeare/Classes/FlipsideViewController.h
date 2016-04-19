//
//  FlipsideViewController.h
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	
	IBOutlet UITextView* infoView;
	IBOutlet UILabel* playLengthLabel;
	IBOutlet UILabel* playsWillHaveLabel;
	IBOutlet UILabel* actsLabel;
	IBOutlet UITextView* copyrightView;
	IBOutlet UILabel* lengthLabel;
	IBOutlet UINavigationItem* titleView;
	
	UISlider* lengthSlider;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

@property (retain, nonatomic) UITextView* infoView;
@property (retain, nonatomic) UILabel* playLengthLabel;
@property (retain, nonatomic) UILabel* playsWillHaveLabel;
@property (retain, nonatomic) UILabel* actsLabel;
@property (retain, nonatomic) UITextView* copyrightView;
@property (retain, nonatomic) UILabel* lengthLabel;
@property (retain, nonatomic) UINavigationItem* titleView;
@property (retain, nonatomic) UISlider* lengthSlider;


- (IBAction)done;
//- (IBAction)lengthSliderMoved:(id)sender;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

