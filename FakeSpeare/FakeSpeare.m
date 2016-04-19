//
//  FakeSpeare.m
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FakeSpeare.h"
#import "RegexKitLite.h"
#import <stdlib.h>

#import <time.h>

//NOTE:changed arc4random() to random() for speed increase

// random testing ******************************************************
/*
//number of trials
#define REPETITIONS (10*1)

//which random function to use (default is random() )
//#define random() arc4random()

*/
// random testing ******************************************************


//the longest title
#define MAX_TITLE_LENGTH 10

//TODO: change these to something reasonable
#define MAX_NUM_CHARACTERS 15

//the default number of acts
#define DEFAULT_PLAY_LENGTH 5

//the maximum number of words in an utterance
#define MAX_UTTERANCE_LENGTH 30
//TODO: some kind of distribution function

//the number of utterances in a scene
#define MAX_NUM_UTTERANCES 20


//the number of scenes per act
#define MAX_NUM_SCENES 4

@implementation FakeSpeare

@synthesize playLength; 

- (id) init {
	
	if (self = [super init]) {
		playLength = DEFAULT_PLAY_LENGTH;
		
		//load the wordfreqdictionary
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
		DLog(@"Init: Loading probability dictionary");
		
		NSString *probabilityFile = [thisBundle pathForResource:@"ProbDict" ofType:@"plist" ];
		
		//load the probability dictionary from file
		//TODO: catch exception - no file exists
		wordFreqDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:probabilityFile];
		DLog(@"Init: Done Loading probability dictionary");
		[wordFreqDictionary retain];//TODO: is this retain right??

		//seed the random() function
		//srandom(time(NULL));

		
		return self;
	}
	
	else {
	 //TODO: error or exception?
		return nil;
	}
	 

	
}

- (NSMutableArray*) composeDramatisPersonae {
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	//NSArray* myBundles = [NSBundle allBundles];
	//DLog(@"%@",myBundles);
	NSString *characterFile = [thisBundle pathForResource:@"characterList" ofType:@"plist" ];
	
	//load the character file
	//NSString* characterFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/characterList.plist";
	
	//load the character array from file
	//TODO: catch exception - no file exists
	NSMutableArray* characterArray = [NSMutableArray arrayWithArray: [NSKeyedUnarchiver unarchiveObjectWithFile:characterFile]];
	
	//choose some number of characters  (between 10 and 20)
	int numDramatisPersonae = (arc4random()%(MAX_NUM_CHARACTERS - 1)) + 1;

	NSMutableArray* outputArray = [NSMutableArray arrayWithCapacity:1];
	
	int whichChar;
	NSString* tempString2 = nil;
	int numCharsLeft;
	for (int ind4 = 0; ind4 < numDramatisPersonae; ind4++) {
		numCharsLeft = [characterArray count];
		whichChar = arc4random()%numCharsLeft;
		
		//add the object, then remove it
		tempString2 = [characterArray objectAtIndex:whichChar];
		[characterArray removeObjectAtIndex:whichChar];
		
		//[outputText appendFormat:@"%@\n",tempString2];
		[outputArray addObject:tempString2];
	}
	
	//return outputText;
	return outputArray;
}

- (NSArray*) composeUtterance: (NSMutableDictionary*) myWordFreqDictionary ofMaxLength:(int)maxUtteranceLength withSeedWord:(NSString*)seedWord endSentenceChars:(NSCharacterSet*)endSentenceChars{
	//TODO:  choose possible start words out of all words used for starting (do this by setting first word as ".")
	
	//TODO:  choose a set of characters in the play
	//TODO:  choose a set of scenes
	//TODO:  user chooses number of acts, at most 9 scenes in each act
	
	//TODO:  should not be iterating through a dictionary, or should not use cumulative frequencies
	//TODO make output text length settable from a slider

	//int maxUtteranceLength = MAX_UTTERANCE_LENGTH;
	int utteranceLength = arc4random()%(maxUtteranceLength-3) + 3;
	//int outputTextLength = playLength; //number of Acts in FakeSpeare
	
		
	//get a list of unique words
	//NSArray* uniqueWords = [wordFreqDictionary allKeys];
	
	//int numUniqWords = [uniqueWords count];
	
	//now, choose a random number
	float randNum;
	
	//choose an initial random word
	
	//TODO: this will crash when numUniqWords == 0
	//TODO: this can lead to empty utterances
	NSString *wordA = seedWord;
	
	NSString *wordB = nil;
	NSDictionary *wordBDict = nil;
	
	NSMutableArray* outputTextArray = [NSMutableArray arrayWithCapacity:utteranceLength];
	//using the 'seed' word, find the next one using wordFreqDictionary
	float tempFreq = 0.0;
	BOOL capitalization = TRUE;
	
	NSRange tempRange;
	
	for (int ind = 0; ind < utteranceLength; ind++) {
		
		//TODO: check if wordA is punctuation or an alphabet word

		//TODO: get rid of all regex references (smaller executable)
		if ([wordA isMatchedByRegex:@"\\W+"]) { //punctuation
			[outputTextArray addObject:wordA];
			
			//TODO: if ".", turn on capitalization
			tempRange = [wordA rangeOfCharacterFromSet: endSentenceChars];
			
			//checking if wordA is not one of !:.?
			if (!NSEqualRanges(tempRange, NSMakeRange(NSNotFound, 0))) {
				capitalization = TRUE;
			}
		}
		else { //alphabetic string
			if (capitalization) { //capitalize wordA
				//TODO:  watch for runtime error! "s" was the wordA value
				
				//TODO: this gives a runtime error when the previous word is "love's"
				[outputTextArray addObject:[@" " stringByAppendingString:[wordA capitalizedString]]];
				capitalization = FALSE;
			}
			else { //TODO: catch exception
				
				[outputTextArray addObject:[@" " stringByAppendingString:wordA]];
				
			}
		}
		
		// a random number between 0 and 1
		randNum = (arc4random()%1000)/1000.0f;
		
		wordBDict = [myWordFreqDictionary objectForKey:wordA] ;
		
		//TODO: faster way to do this?
		//iterate throught wordBDict until we are greater than randNum
		for (wordB in wordBDict) {
			tempFreq = tempFreq + [[wordBDict valueForKey:wordB] floatValue];
			
			// break out of the loop if this entry's cumulative frequency is greater than randNum
			if (tempFreq > randNum) {//TODO: >= or >?
				break;
			}
		}
		
		wordA = wordB; //new word pair	

		//TODO:  this is a hack since the title prob dict does not contain "tale".  Need to fix the title prob dict
		if ([wordA isEqualToString:@"tale"]) {
			break;
		}
		tempFreq = 0.0;
	}
		
	// if endSentenceChars empty, do not do this step
	
	//stop when first "." reached after ind >= outputTextLength (ie. we want the play to end with a ".", not something else.)
	NSCharacterSet* emptySentenceChars = [NSCharacterSet characterSetWithCharactersInString: @""];

	if (![endSentenceChars isEqual:emptySentenceChars]) {
		while(TRUE) { 
			
			//stop if we are ending a sentence
			if ([wordA isEqualToString: @"."] || [wordA isEqualToString:@"!"] || [wordA isEqualToString:@"?"]){
				[outputTextArray addObject:wordA];
				break; // break out of while
			}
			else {
				//TODO: get rid of all regex references (smaller executable)
				if ([wordA isMatchedByRegex:@"\\W+"]) { //punctuation
					[outputTextArray addObject:wordA];
				}
				else { //alphabetic string
					[outputTextArray addObject:[@" " stringByAppendingString:wordA]];
				}
			}
			
			// a random number between 0 and 1
			randNum = (arc4random()%1000)/1000.0f;
			
			wordBDict = [myWordFreqDictionary objectForKey:wordA] ;
			
			//TODO: faster way to do this?
			//iterate throught wordBDict until we are greater than randNum
			for (wordB in wordBDict) {
				tempFreq = tempFreq + [[wordBDict valueForKey:wordB] floatValue];
				
				// break out of the loop if this entry's cumulative frequency is greater than randNum
				if (tempFreq > randNum) {//TODO: >= or >?
					break;
				}
			}
			
			wordA = wordB; //new word pair	
			
			//TODO:  this is a hack since the title prob dict does not contain "tale".  Need to fix the title prob dict
			if ([wordA isEqualToString:@"tale"]) {
				break;
			}
			
			tempFreq = 0.0;
			
		}
	}

	//TODO: make sure to handle empty utterances

	//only remove first object if it is "."
	if ([seedWord isEqualToString: @"."]) {
		[outputTextArray removeObjectAtIndex:0];
	}
	

	return outputTextArray;
} 

- (NSMutableString*) composeScene:(NSMutableArray*) dramatisPersonaeArray withFreqDict:(NSMutableDictionary*)myWordFreqDictionary {

	NSMutableString* outputText = [NSMutableString stringWithCapacity:1]; //TODO, should this be init'd otherwise?

	int maxNumUtterances = MAX_NUM_UTTERANCES;
	
	//choose number of characters in scene
	int numCharacters = arc4random()%[dramatisPersonaeArray count]+1;
	
	//choose number of utterances
	//TODO: make sure is at least 1
	int numUtterances = arc4random()%maxNumUtterances+1;

	NSString* tempCharacterName = nil;

	NSCharacterSet* endSentenceChars = [NSCharacterSet characterSetWithCharactersInString: @".:!?"];

	//create the utterances
	for (int ind5 = 0; ind5< numUtterances; ind5++) {
		
		//for each utterance, choose a character
		tempCharacterName = [dramatisPersonaeArray objectAtIndex:(arc4random()%numCharacters)];
		[outputText appendString:tempCharacterName];
		[outputText appendString:@":"];
		[outputText appendString: [[self composeUtterance: myWordFreqDictionary ofMaxLength:MAX_UTTERANCE_LENGTH withSeedWord:@"." endSentenceChars:endSentenceChars] componentsJoinedByString:@""]];
		[outputText appendString:@"\n\n"];
	}
	[outputText appendString:@"\n"];
	return outputText;
}

//TODO: add scenes parameter (NSArray of strings)
- (NSMutableString*) composeAct:(NSMutableArray*) dramatisPersonaeArray withFreqDict:(NSMutableDictionary*)myWordFreqDictionary {
	
	NSMutableString* outputText = [NSMutableString stringWithCapacity:1]; //TODO, should this be init'd otherwise?
		
	// choose a random number of scenes
	int maxNumScenes = MAX_NUM_SCENES;

	//TODO: insert "Enter so and so", "Exit so and so"
	int numScenes = arc4random()%maxNumScenes + 1;
	for (int sceneNum = 0; sceneNum < numScenes; sceneNum++) {
		[outputText appendString:[NSString stringWithFormat:@"Scene %d\n",sceneNum + 1]];
		//TODO: insert scene information
		
		[outputText appendString: [self composeScene:dramatisPersonaeArray withFreqDict: myWordFreqDictionary]];	
	}
	
	return outputText;
}


//create the title, make sure we don't use a real Shakespeare title
- (NSMutableString*) composeTitle {
	
	//TODO:  make sure we don't use a real Shakespeare title
	
	//load the probability file
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	
	//	NSString *probabilityFile = [thisBundle pathForResource:@"ProbDict" ofType:@"plist" ];

	//TODO: "tale" wasn't put in the dictionary!
	NSString *probabilityFile = [thisBundle pathForResource:@"TitleProbDict" ofType:@"plist" ];
	NSMutableDictionary* titleProbDict = [NSKeyedUnarchiver unarchiveObjectWithFile:probabilityFile];
	
	//load the existing titles file
	NSString *origTitlesFile = [thisBundle pathForResource:@"OrigTitles" ofType:@"plist" ];
	
	NSArray *tempTitlesArray = [NSKeyedUnarchiver unarchiveObjectWithFile:origTitlesFile];
	
	//strip the last entry
	NSRange range = NSMakeRange(0, [tempTitlesArray count] - 1);
	NSArray *origTitlesArray = [tempTitlesArray subarrayWithRange:range];
	
	//iterate through, generating title, 
	//TODO: don't end on "THE" (and several other words)
	NSString *seedWord = nil;
	
	//choose seedword from among all actual title beginnings
	
	//choose a random original title
	NSString *tempTitle = [origTitlesArray objectAtIndex:arc4random()%[origTitlesArray count]];
	
	//get the first word
	//TODO: problem, this grabs bad seedwords such as "love's"
	//seedWord = [[[tempTitle componentsSeparatedByString:@" "] objectAtIndex:0] lowercaseString];
	
	//make an alphabetic characterset, then negate it
	NSCharacterSet *alphabetChars = [NSCharacterSet uppercaseLetterCharacterSet];
	//DLog(@"%@", alphabetChars);
	NSCharacterSet *nonAlphabetChars = [alphabetChars invertedSet];
	
	seedWord = [[[tempTitle componentsSeparatedByCharactersInSet:nonAlphabetChars] objectAtIndex:0] lowercaseString];
	//DLog(@"seedword %@", seedWord);
	
	//we want to end the utterance without punctuation
	NSCharacterSet* endSentenceChars = [NSCharacterSet characterSetWithCharactersInString: @""];

	NSMutableArray* tempTitleArray = [NSMutableArray arrayWithArray:[self composeUtterance:titleProbDict ofMaxLength:MAX_TITLE_LENGTH withSeedWord:seedWord endSentenceChars:endSentenceChars]];
	
	//TODO: capitalize each word, capitalize roman numerals, make "S" lower case
	NSArray *numeralMapping = [NSArray arrayWithObjects: @" i",@" ii",@" iii",@" iv", @" v", @" vi", @" vii", @" viii", @" ix", @" x", nil];

	NSString *tempString;
	//DLog(@"temp title array before capitalizing: %@", tempTitleArray);
	
	for (int ind345 = 0; ind345 < [tempTitleArray count]; ind345++) {
		tempString = [tempTitleArray objectAtIndex:ind345];
	
		if ([numeralMapping containsObject: tempString]) {
			tempString = [tempString uppercaseString];
			[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];
		}
		else if ([tempString isEqualToString: @" S" ] || [tempString isEqualToString:@" s"]) {
			tempString = @"s";
			[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];

		}
		else {
			tempString = [tempString capitalizedString];
			[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];
		}
	}
	//DLog(@"temp title array after capitalizing: %@", tempTitleArray);

	NSMutableString *titleString = [NSMutableString stringWithString: [tempTitleArray componentsJoinedByString:@""]];

	//NSMutableString *titleString = [NSMutableString stringWithString:[[self composeUtterance:titleProbDict ofMaxLength:MAX_TITLE_LENGTH withSeedWord:seedWord endSentenceChars:endSentenceChars] capitalizedString]];
	//DLog(@"titlestring is: %@",titleString);
	
	//TODO: check that our new title is not in the originalTitlesArray
	//TODO: check that our new title is not a subset of an existing title 
	//(ie. "THE TRAGEDY OF OTHELLO" is a substring of "THE TRAGEDY OF OTHELLO, MOOR OF VENICE")
	//TODO: how to deal with disconnected title subgraphs in the titleProbDict ?
	
	//TODO: don't end on "THE" (and several other words)  (Not sure this is working)
	//NSArray *badEndingWords = [NSArray arrayWithObjects:@"The",@"Of",@"\'",@"And",@",",@"'", @"A",nil];
	
	//	NSMutableArray *titleArray;
	
	//TODO: problem with capitalization when searching?
	while ([origTitlesArray indexOfObject:[titleString uppercaseString]] != NSNotFound) {
		
		//DLog(@"Not original title, trying again");
		
		//choose seedword from among all actual title beginnings
		tempTitle = [origTitlesArray objectAtIndex:arc4random()%[origTitlesArray count]];
		seedWord = [[[tempTitle componentsSeparatedByString:@" "] objectAtIndex:0] lowercaseString];
		
		tempTitleArray = [NSMutableArray arrayWithArray:[self composeUtterance:titleProbDict ofMaxLength:MAX_TITLE_LENGTH withSeedWord:seedWord endSentenceChars:endSentenceChars]];
		
		//TODO: capitalize each word, capitalize roman numerals, make "S" lower case
		
		for (int ind345 = 0; ind345 < [tempTitleArray count]; ind345++) {
			tempString = [tempTitleArray objectAtIndex:ind345];
			
			if ([numeralMapping containsObject: tempString]) {
				tempString = [tempString uppercaseString];
				[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];
			}
			else if ([tempString isEqualToString: @"S" ]) {
				tempString = @"s";
				[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];
				
			}
			else {
				tempString = [tempString capitalizedString];
				[tempTitleArray replaceObjectAtIndex:ind345 withObject:tempString];
			}
		}
		
			 
		titleString = [NSMutableString stringWithString: [tempTitleArray componentsJoinedByString:@""]];
		
		//titleString = [NSMutableString stringWithString:[[self composeUtterance:titleProbDict ofMaxLength:MAX_TITLE_LENGTH withSeedWord:seedWord endSentenceChars:endSentenceChars] capitalizedString]];

	}
	
	//TODO: don't end on "THE" (and several other words)  (Not sure this is working)
	//TODO: this might lead to titles identical to shakespeare
	NSArray *badEndingWords = [NSArray arrayWithObjects:@"The",@"Of",@"\'",@"And",@",",@"'", @";", @"Or", @"A", @"For",@"As",nil];
	
	NSMutableArray *titleArray;
	
	
	titleArray = [NSMutableArray arrayWithArray:[titleString componentsSeparatedByString:@" "]];
	
	
	
	//remove strange words at end of title
	//DLog(@"titleArray lastObject %@",[titleArray lastObject]);
	while ([badEndingWords containsObject: [titleArray lastObject]]) {
		//DLog(@"Removing %@", [titleArray lastObject]);

		[titleArray removeLastObject];
		
	}
	
	return [NSMutableString stringWithString:[titleArray componentsJoinedByString:@" "]];
}



/*
TODO:  Idea: have threads in plot somehow, in which characters are involved. 
 
TODO: For now, make sure we use all of the characters.
 
 */
-(NSMutableString*) composeText {

	NSMutableString *outputText;
	
// random testing ******************************************************
/*	

	
	NSTimeInterval	start = [NSDate timeIntervalSinceReferenceDate];
	
	for (int ind12312 = 0; ind12312 < REPETITIONS; ind12312++) {

		
*/
// random testing ******************************************************

		outputText = [self composeTitle];

		// get the characters in play
		NSMutableArray* dramatisPersonaeArray = [self composeDramatisPersonae];
		NSMutableString* tempDramatisPersonae = [NSMutableString stringWithString:[dramatisPersonaeArray componentsJoinedByString:@"\n"]];
		
		//TODO:  handle bundle dir, etc.
		//TODO:  handle file not found
		//NSString* probabilityFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/ProbDict.plist";
		
		//TODO: The wordFreqDictionary has to be loaded already
		
		
		// add them to the output
		[outputText appendString:@"\n\n"];
		[outputText appendString:[NSMutableString stringWithString: @"Dramatis Personae:\n\n"]];
		[outputText appendString: tempDramatisPersonae];	
		[outputText appendString:@"\n\n"];
		
		//so we can write roman numerals for Acts instead of integers
		NSArray *numeralMapping = [NSArray arrayWithObjects: @"I",@"II",@"III",@"IV", @"V", @"VI", @"VII", @"VIII", @"IX", @"X", nil];
		
		for (int actNum = 0; actNum < playLength; actNum++) {
			//TODO: should be in Roman Numerals
			//DLog(@"Composing Act %d", actNum);
			[outputText appendString:[NSString stringWithFormat:@"Act %@ ",[numeralMapping objectAtIndex: actNum]]]; 
			
			//TODO: pass Act# to composeAct, so it can print "Act IV, scene 3", etc. for each scene
			[outputText appendString:[self composeAct:dramatisPersonaeArray withFreqDict:wordFreqDictionary]];
		}
		
		[outputText appendString: @"\n\nFinis"];
		
		//TODO: release objects?
		
// random testing ******************************************************
/*
	}
	NSTimeInterval	end = [NSDate timeIntervalSinceReferenceDate];
	NSLog(@"arc4random(); %d repetitions", REPETITIONS);

	NSLog(@"time = %g secs", (end - start));
*/
// random testing ******************************************************

	return outputText;
}

-(void) dealloc {
	[wordFreqDictionary release];//TODO: Is this correct?
	[super dealloc];
}

@end
