//
//  FakeSpeare.h
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* The model, this class handles text creation, primarily:
 
 - reading probability and other saved data to compose a "play", and associated text processing
 
 */

#import <Foundation/Foundation.h>




@interface FakeSpeare : NSObject {
	
	int playLength;
	NSMutableDictionary* wordFreqDictionary;
}

@property int playLength; // read-write by default

// number of words in the play
//- (void) setPlayLength:(int) length;
- (id) init;

//TODO both of these should use a base directory from the bundle, etc.
- (NSMutableArray*) composeDramatisPersonae;

//one utterance
- (NSArray*) composeUtterance:(NSMutableDictionary*)wordFreqDictionary ofMaxLength:(int)maxUtteranceLength withSeedWord:(NSString*)seedWord endSentenceChars:(NSCharacterSet*)endSentenceChars;

//one scene
- (NSMutableString*) composeScene:(NSMutableArray*) dramatisPersonaeArray withFreqDict:(NSMutableDictionary*)wordFreqDictionary ;

//one act
- (NSMutableString*) composeAct:(NSMutableArray*) dramatisPersonaeArray withFreqDict:(NSMutableDictionary*)wordFreqDictionary;


//generate FakeSpeare by reading in a word-pair probabilities file
- (NSMutableString*) composeText;

//create the title
- (NSMutableString*) composeTitle;

@end
