//
//  TextParser.m
//  FakeSpeare
//
//  Created by Galen Wilkerson on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TextParser.h"

//TODO: Am I supposed to import this in .h instead?
#import "RegexKitLite.h"


@implementation TextParser

-(NSArray*) readText: (NSString*) inputFilename{
	//read a text file and get the complete text as an array
	//load the data
	
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:inputFilename
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
	
	if (stringFromFileAtPath == nil) {
		DLog(@"Error reading file at %@\n%@",
              inputFilename, [error localizedFailureReason]);
		return nil;
	}
	else	{
		//textView1.text = stringFromFileAtPath;
	}
	
	// parse into words
	
	//replace non-letter <char> with <space><char> to allow parsing
	
	NSString *completeTextString = nil;
	NSString *regexString1       = @"\\b(\\W+)\\b";
	NSString *replaceWithString = @" $1 ";
	
	completeTextString = [stringFromFileAtPath stringByReplacingOccurrencesOfRegex:regexString1 withString:replaceWithString];
	[stringFromFileAtPath release];
	NSString *regexString  = @"\\s+";
	
	//the complete text as an array of strings, first converting to lowercase
	NSArray  *completeTextArray   = [[completeTextString lowercaseString] componentsSeparatedByRegex:regexString];
	return completeTextArray;
	
}

/*
//remove all bad characters
-(NSString*) stripOutBad: (NSString*) inputFilename {
	
}
*/

//parse out the character names
-(NSArray*) parseCharacterNames: (NSString*) inputFilename {
	
// use RegexKitLite to parse input file 
	
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:inputFilename
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
	
	if (stringFromFileAtPath == nil) {
		DLog(@"Error reading file at %@\n%@",
              inputFilename, [error localizedFailureReason]);
		return nil;
	}
	else	{
		//textView1.text = stringFromFileAtPath;
	}
	
	
	NSArray* dramatisPersonaeStrings = nil;
	dramatisPersonaeStrings	= [stringFromFileAtPath componentsSeparatedByRegex:@"\n"];
	[stringFromFileAtPath release];
	//extract and store character name abbreviations how?
	
	return dramatisPersonaeStrings;
	
	
	//NSLog(@"The characters: %@", dramatisPersonaeStrings);
	
}


//parse out stage directions for later use
/*-(NSArray*) parseStageDirections: (NSString*) inputFilename {
	
}
*/

-(NSMutableDictionary*) calcWordCounts:(NSArray*) completeTextArray uniqueWordsArray:(NSArray*) uniqueWords
{
	
	
	/* Load the data file,
	 parse into words,
	 create word-pair matrix,
	 count word-pairs
	 calculate frequencies
	 convert to cumulative frequencies
	 save to file (or otherwise use data persistence */
	
	int numUniqWords = [uniqueWords count];
	
	int completeTextArrayLength = [completeTextArray count];
	/*
	 // store word A's in dictionary
	 // key is word A
	 // value is a NSMutableDictionary of wordB's
	 //
	 // wordB dictionary has wordB as key
	 // the value is the count, then becomes the frequency, and finally the cumulative frequency
	 //
	 //	
	 // will this suit our purposes?
	 // fast?
	 // speed of dictionary access, perhaps convert to NON-mutable once we are done creating, for storage
	 //
	 // small?  
	 // roughly the size of a linked list, only has non-zero entries, seems small
	 // index by cumulative frequency?  (use fast enumeration)
	 */
	
	//create a mutable dictionary for wordA's
	NSMutableDictionary *wordADict = nil;
	wordADict = [[NSMutableDictionary alloc] initWithCapacity:numUniqWords];
	
	//create a mutable dictionary to keep count
	NSMutableDictionary *wordATotalCountDict = [NSMutableDictionary dictionaryWithCapacity:numUniqWords];
	
	NSString* key;
	
	//zero out the count dictionary
	for (key in uniqueWords) {
		[wordATotalCountDict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
	
	NSString* wordA = nil;
	NSString* wordB = nil;
	int wordAIndex, wordBIndex = 0;
	int countVal = 0;
	int totalCount = 0;
	
	//read completeTextArray.  Each time, a wordpair is added to wordADict
	//iterate through all except the next-to-last word
	for (wordAIndex	= 0; wordAIndex < (completeTextArrayLength - 1); wordAIndex++) {
		wordBIndex = wordAIndex + 1;
		
		wordA = [completeTextArray objectAtIndex:wordAIndex]; 
		wordB = [completeTextArray objectAtIndex: wordBIndex];
		
		// now insert an entry in wordADict
		// first check that there is an entry corresponding to wordA
		NSMutableDictionary* tempWordADictEntry = [wordADict objectForKey:wordA];
		
		//keep a running count of the number of occurences of wordA
		totalCount = [[wordATotalCountDict objectForKey:wordA] intValue] +1;
		
		[wordATotalCountDict setObject:([NSNumber numberWithInt: totalCount]) forKey:wordA];
		
		if (tempWordADictEntry == nil) //no such entry, create entry, add object, increment count
		{ 
			NSMutableDictionary* tempBDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt: 1] forKey:wordB];
			[wordADict setObject:tempBDict forKey:wordA];
		}
		
		else //there is such an entry, increment its count value by one
		{	
			countVal = [[tempWordADictEntry objectForKey:wordB] intValue];
			
			[tempWordADictEntry setObject:[NSNumber numberWithInt: (countVal +1)] forKey:wordB];
			
		}		
	}
	
	//TODO: release stuff!? check memory management protocols
	
	return wordADict;
}

//convert the wordCountDict to dictionary of dictionary of cumulative word freqencies
- (NSMutableDictionary*) calcWordFreq:(NSDictionary*) wordCountDict {
	
	//Need to get the total of all the values in each dictionary of wordCountDict
	
	//enumerate through the objects in wordCountDict
	NSDictionary* wordBDict1 = nil;
	
	// the array where we will store the total value counts for each wordA occurence
	NSMutableDictionary* wordATotalCountDict = [[NSMutableDictionary alloc] initWithCapacity:[wordCountDict count]];
	
	int sum = 0;
	NSString* wordA = nil;
	NSString* wordB = nil;
	
	//find the total values
	//TODO: use key-value coding for all of this
	//TODO:  This could be done just by iterating through completeTextArray using each entry in uniqueWords
	
	for (wordA in wordCountDict) {
		
		wordBDict1 = [wordCountDict objectForKey:wordA];
		
		for (wordB in wordBDict1) {
			sum = sum + [[wordBDict1 valueForKey:wordB] intValue];
		}
		
		[wordATotalCountDict setValue:[NSNumber numberWithInt:sum]	forKey:wordA];
		sum = 0;
	}
	
	
	//convert counts to frequencies (how often wordB follows a particular wordA)
	//for each wordA in uniqWords
	//look in wordADict, get list of all keys
	//enumerate through the keys
	//divide each entry by the wordATotalCountDict entry for wordA
	//TODO: key value coding for speed
	
	
	//can't alter a dictionary being enumerated
	//use wordCountDict for reading count values
	//use wordBDictRead fore reading sub-dictionary count values
	
	//use wordFreqDict for setting frequency values
	//use wordBDictWrite for writing frequency values
	
	//TODO: copy the wordCountDict, so we don't make changes to it
	NSMutableDictionary *wordFreqDict = [wordCountDict copy];
	
	NSMutableDictionary* wordBDictRead = nil;
	NSMutableDictionary* wordBDictWrite = nil;
	
	int tempCount = 0;
	float tempFreq = 0.0;
	//TODO: Note: we can speed this up by only looking at wordB dictionaries with more than one entry, otherwise just copy
	// ie. if the word-pair occurs once, we don't have to calculate anything (that is, most of the time)
	for (wordA in wordCountDict) {
		
		// get the NSMutableDictionaries for reading and writing
		wordBDictRead = [wordCountDict objectForKey:wordA];
		wordBDictWrite = [wordFreqDict objectForKey:wordA];
		
		NSArray* wordBDictReadKeys = [wordBDictRead allKeys];

		for (wordB in wordBDictReadKeys) {
			
			//get the count stored for each key
			tempCount = [[wordBDictRead valueForKey:wordB] intValue];
			
			//determine the frequency by dividing by the total for this wordA
			tempFreq = tempCount/[[wordATotalCountDict valueForKey:wordA] floatValue] ;
			
			// now replace the count value by the temp frequency
			[wordBDictWrite setValue:[NSNumber numberWithFloat:tempFreq] forKey:wordB];
			
		}
	}
	
	//TODO: any releasing?
	return wordFreqDict;
	
}


//load the data file and calculate all of the cumulative wordpair probabilities
//save the resulting data structures to disk
-(void) calculateWordPairProbabilities {
	
	//TODO:  handle file not found
	//NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	//NSString *path = [thisBundle pathForResource:@"As_You_Like_It" ofType:@"txt" ];
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *textfilePath = [thisBundle pathForResource:@"plays_text_stripped_split" ofType:@"txt" ];
	
	NSArray *completeTextArray = [self readText:textfilePath];
	 
	// get list of unique words
	NSArray *uniqueWords = [[NSSet setWithArray:completeTextArray] allObjects];
	
	//get a mutable dictionary containing all word-pair counts
	NSMutableDictionary* wordCountsDictionary = [self calcWordCounts:completeTextArray uniqueWordsArray: uniqueWords];
	
	//Now, change the counts to cumulative frequencies
	NSMutableDictionary* wordFreqDictionary = [self calcWordFreq:wordCountsDictionary];	
	
	//archive the probability frequencies and the character array
	//TODO: handle unable to write file (no space, etc.) error or exception?
	NSString* probabilityFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/ProbDict.plist";
	//NSString *probabilityFile = [thisBundle pathForResource:@"ProbDict" ofType:@"plist" ];

	[NSKeyedArchiver archiveRootObject:wordFreqDictionary toFile:probabilityFile];
	
	//TODO: NSString* characterArrayFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/CharacterArray.plist";
	//TODO: [NSKeyedArchiver archiveRootObject:characterArray toFile:probabilityFile];
	 	 
	//Now, save the list of characters
	
	//grab the list of character names
	//TODO: use this information carfully.  Remove them from the list of words, including abbreviations. 
	//TODO: Could also determine length of utterances, mood of utterance, etc.
	//NSString *characterFilePath = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/characters_stripped.txt";
	NSString *characterFilePath = [thisBundle pathForResource:@"characters_stripped" ofType:@"txt" ];

	NSArray *characterArray = [self parseCharacterNames: characterFilePath];
	
	//NSString* characterFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/characterList.plist";
	NSString *characterFile = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingString:@"characterList.plist"];
	//[thisBundle pathForResource:@"characterList" ofType:@"plist" ];

	[NSKeyedArchiver archiveRootObject:characterArray toFile:characterFile];
	
}

//create probability file for title names
- (void) calculateTitleProbabilities  {
/*
	load the title textfile
	
	get a list of titles
	put a period at the end of each (when composing, we will stop on . and not show it)
*/
	
	//read the titles
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *textfilePath = [thisBundle pathForResource:@"titles" ofType:@"txt" ];
	
	NSArray *completeTextArray = [self readText:textfilePath];
	NSError *error;
	
	//load the array of all titles
	NSString *originalText =  [[NSString alloc] initWithContentsOfFile:textfilePath encoding:NSUTF8StringEncoding error:&error];
	
	NSArray *originalTitlesArray = [originalText componentsSeparatedByString:@"\n"];
	[originalText release];
	
	//go through complete text array and prepend "." (helps with composition)
	//NSString *tempWord = nil;

	//hopefully this will add a "." at the beginning of each 
	/*
	 for (tempWord in completeTextArray) {		
		tempWord = [@"." stringByAppendingString:tempWord];
	}
	 */
		
	/*
	NSMutableArray *inputCompleteTextArray = [NSMutableArray arrayWithArray: [self readText:textfilePath]];
	
	//iterate through array, inserting .'s (period)
	
	 NSString *tempTitle;
	for (int ind234 = 0; ind234 < [inputCompleteTextArray count]; ind234++) {
		tempTitle = [inputCompleteTextArray objectAtIndex:ind234];
		[inputCompleteTextArray 
	}
	*/
	
	// get list of unique words
	NSArray *uniqueWords = [[NSSet setWithArray:completeTextArray] allObjects];
	
	//get a mutable dictionary containing all word-pair counts
	NSMutableDictionary* wordCountsDictionary = [self calcWordCounts:completeTextArray uniqueWordsArray: uniqueWords];
	
	//Now, change the counts to cumulative frequencies
	NSMutableDictionary* wordFreqDictionary = [self calcWordFreq:wordCountsDictionary];	
	
	//archive the probability frequencies 
	//TODO: handle unable to write file (no space, etc.) error or exception?
	//NSString* probabilityFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/ProbDict.plist";
	//NSString *probabilityFile = [thisBundle pathForResource:@"TitleProbDict" ofType:@"plist" ];
	NSString *probabilityFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/TitleProbDict.plist";
	[NSKeyedArchiver archiveRootObject:wordFreqDictionary toFile:probabilityFile];
	
	//archive the original titles
	NSString *origTitlesFile = @"/Users/galenwilkerson/Work/iPhone/Projects/Development/FakeSpeare/Data/OrigTitles.plist";
	[NSKeyedArchiver archiveRootObject:originalTitlesArray toFile:origTitlesFile];
	
}


@end
