//
//  TextParser.h
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 class to handle parsing of text and creation of data files for play composing
 */

#import <Foundation/Foundation.h>


@interface TextParser : NSObject {

}

/*
 Two stages:
 
 1.
 Read the text
 
 get character names
 
	use character names to remove from play
 
 
    // get scene names (not high priority)  (next release)
 
 2.
 strip out character names, scenes, and junk characters (any ref to gutenberg, etc.)
 
 save raw text file
 
 
 */

 /*
	 To remove:
	 - all numbers
	 - all sections between << >> 
		- this separates every act
	 - all references to gutenberg
	 - all acts
	 - for now, every stage direction (if possible)
		 - between [ ]
	 - handle parenthetical comments  ( )
		- either strip out, or use, but close parens
	
	 - other characters
	 
	 */

	//TODO: would be nice to insert "Enter so-and-so" before they speak, and after they leave.
	//TODO: grab scenes
	
	
// - every play seems to begin with DRAMATIS PERSONAE (caps or lower case), and end with "THE END"
 

//TODO:  don't make all input text lower case, preserve case
//TODO:  remove characters from input text (or take into account that they are there)

//TODO:  choose possible start (of utterance) words out of all words used for starting (start from .)

//using the complete path, read the text into an NSArray of Strings
- (NSArray*) readText: (NSString*)inputFilename;

//remove all bad characters from the file
//-(NSString*) stripOutBad: (NSString*) inputFilename;

//parse out the character names for later use
- (NSArray*) parseCharacterNames: (NSString*) inputFilename;

//parse out stage directions for later use
//- (NSArray*) parseStageDirections: (NSString*) inputFilename;

//calculate the word-pair counts, passing the complete text as an array, along with a list of unique words
- (NSMutableDictionary*) calcWordCounts:(NSArray*) completeTextArray uniqueWordsArray:(NSArray*) uniqueWords;

//convert the wordCountDict to dictionary of dictionary of cumulative word freqencies
//TODO:  Use NSNumber with char or short int to reduce the size of the wordCountDict
//TODO:  Use NSValue to wrap unsigned short int or so
- (NSMutableDictionary*) calcWordFreq:(NSDictionary*)wordCountDict;

//reads in a text file, calculates the cumulative word-pair probabilities,
//archives this to disk for future usage
- (void) calculateWordPairProbabilities;

//create probability file for title names
- (void) calculateTitleProbabilities;

@end
