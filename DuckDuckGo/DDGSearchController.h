//
//  DDGSearchController.h
//  DuckDuckGo2
//
//  Created by Chris Heimark on 12/9/11.
//  Copyright (c) 2011 DuckDuckGo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DataHelper.h"
#import "CacheController.h"
#import "DDGSearchHandler.h"

enum eSearchState
{
	eViewStateHome = 0,
	eViewStateWebResults
	
};

@interface DDGSearchController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate>
{
	IBOutlet UITableView		*tableView;

	IBOutlet UITableViewCell	*loadedCell;
	IBOutlet UITextField		*__weak search;
	IBOutlet UIButton			*__weak searchButton;
	
	enum eSearchState			state;
	CGRect						kbRect;
	
	id<DDGSearchHandler>		__unsafe_unretained searchHandler;
	
	NSMutableURLRequest			*serverRequest;
    
    NSMutableDictionary *suggestionsCache;
}

@property (nonatomic, strong) NSMutableURLRequest			*serverRequest;

@property (nonatomic, strong) NSMutableDictionary			*serverCache;

@property (nonatomic, strong) IBOutlet		UITableViewCell	*loadedCell;
@property (nonatomic, readonly) IBOutlet	UITextField		*search;
@property (nonatomic, weak) IBOutlet		UIButton		*searchButton;

@property (nonatomic, assign) enum eSearchState			state;

@property (nonatomic, unsafe_unretained) id<DDGSearchHandler>		searchHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil view:(UIView*)parent;

- (IBAction)searchButtonAction:(UIButton*)sender;


-(NSArray *)currentSuggestions;
-(void)downloadSuggestionsForSearchText:(NSString *)searchText;


// TODO (ishaan): make these private?
-(void)revealAutocomplete:(BOOL)reveal;
-(void)updateBarWithURL:(NSURL *)url;
-(NSString *)validURLStringFromString:(NSString *)urlString;


@end

UIKIT_EXTERN NSString *const ksDDGSearchControllerServerKeySnippet; 
UIKIT_EXTERN NSString *const ksDDGSearchControllerServerKeyPhrase; 
UIKIT_EXTERN NSString *const ksDDGSearchControllerServerKeyImage; 

