//
//  DDGTopicsTrendsPick.m
//  DuckDuckGo2
//
//  Created by Chris Heimark on 12/9/11.
//  Copyright (c) 2011 DuckDuckGo, Inc. All rights reserved.
//

#import "DDGTopicsTrendsPick.h"
#import "DDGWebViewController.h"
#import "UtilityCHS.h"
#import "JSON.h"
#import "NSString+SBJSON.h"

#define kElementsInCellPortrait	3

static NSString *TopicsTrendsPickCellIdentifier = @"TopicsTrendsPickCell";

@implementation DDGTopicsTrendsPick

@synthesize loadedCell;
@synthesize tableView;
@synthesize entries;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	// Do any additional setup after loading the view, typically from a nib.
	
	dataHelper = [[DataHelper alloc] initWithDelegate:self];

	[tableView registerNib:[UINib nibWithNibName:TopicsTrendsPickCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TopicsTrendsPickCellIdentifier];
	
	self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:12.0/255.0 alpha:1.0]; //[UIColor colorWithPatternImage:[UIImage imageNamed:@"blackBar4x44.png"]];
	
	UILabel *lbl = (UILabel*)[self.view viewWithTag:100];
	lbl.text = NSLocalizedString (@"Pick Topics + Sources", nil);
	
	UIButton *button = (UIButton*)[self.view viewWithTag:200];
	[button setTitle: NSLocalizedString (@"Add Custom Topics", nil) forState:UIControlStateNormal];

	[self loadEntries];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	self.entries = nil;
	[dataHelper release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[tableView reloadData];
}

#pragma - user actions

- (IBAction)done:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)topicChosen:(id)sender
{
	NSInteger dataIndex = ((UIButton*)sender).tag;
	
	NSDictionary *entry = [entries objectAtIndex:dataIndex];
	
	NSLog(@"topicChosen: %@", entry);
	
//	NSString *urlString = [[entry objectForKey:@"target"] objectForKey:@"url"];
//	if (urlString)
//	{
//		DDGWebViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
//		
//		urlString = [UtilityCHS fixupURL:urlString];
//		
//		wvc.params = [NSDictionary dictionaryWithObjectsAndKeys:
//					  [NSURL URLWithString:urlString], @"homeScreenLink", 
//					  nil];
//		
//		[self.navigationController pushViewController:wvc animated:YES];
//	}
}


// 65, 43; 158, 43; 251, 43

#pragma  mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGPoint pt = CGPointMake ([UtilityCHS portrait:self.navigationController.interfaceOrientation] ? 65.0 : 65.0+93.0, 43.0);
	
	for (NSInteger tagIndex = 100; tagIndex <= (100 * kElementsInCellPortrait); tagIndex += 100, pt.x += 93.0)
		[cell.contentView viewWithTag:tagIndex].center = pt;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:TopicsTrendsPickCellIdentifier];
	
	if (!cell) return nil;
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	NSInteger dataIndex = indexPath.row * kElementsInCellPortrait;
	
	for (NSInteger tagIndex = 100; tagIndex <= (100 * kElementsInCellPortrait); tagIndex += 100, ++dataIndex)
	{
		UIImageView *iv	= (UIImageView *)[cell.contentView viewWithTag:tagIndex+1];
		UILabel *lbl	= (UILabel *)    [cell.contentView viewWithTag:tagIndex+2];
		
		if (dataIndex < [entries count])
		{
			NSDictionary *entry = [entries objectAtIndex:dataIndex];
			
			NSDictionary *media = [entry objectForKey:@"target"];
			
			if ([[media objectForKey:@"mytype"] isEqual:@"image"] && [media objectForKey:@"medium_thumbnail"])
				iv.image = [self loadImage:[media objectForKey:@"medium_thumbnail"]];
			else
				iv.image = nil;
			
			lbl.text = [entry objectForKey:@"content"];
			
			// third element IS ALWAYS the button
			UIButton *button = (UIButton*)[[[cell.contentView viewWithTag:tagIndex] subviews] objectAtIndex:2];
			// mark the data index this button maps to
			button.tag = dataIndex;
			
			if (![button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside])
				// this guy does have a control target setup yet
				[button addTarget:self action:@selector(topicChosen:) forControlEvents:UIControlEventTouchUpInside];
			
			[cell.contentView viewWithTag:tagIndex].hidden = NO;
		}
		else
		{
			iv.image = nil;
			lbl.text = nil;
			[cell.contentView viewWithTag:tagIndex].hidden = YES;
		}
	}
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (![entries count])
		return 0;

	if (!([entries count] % kElementsInCellPortrait))
		return [entries count] / kElementsInCellPortrait;

	return ([entries count] / kElementsInCellPortrait) + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 90.0;
}

#pragma  mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma - load up entries

- (UIImage*)loadImage:(NSString*)url
{
	NSData *img = [dataHelper retrieve:url
								 store:kCacheStoreIndexImages
								  name:[NSString stringWithFormat:@"%08x", [url hash]]
							returnData:YES
							identifier:2000
							bufferSize:8192];
	if (img)
		return [UIImage imageWithData:img];
	return nil;
}

- (void)loadEntries
{
	[dataHelper retrieve:@"http://otter.topsy.com/top.json?thresh=top100&type=image&locale=en&family_filter=1"
				   store:kCacheStoreIndexNoFileCache
					name:nil
			  returnData:NO
			  identifier:1000
			  bufferSize:8192];
}


#pragma mark - DataHelper delegate

- (void)dataReceivedWith:(NSInteger)identifier andData:(NSData*)data andStatus:(NSInteger)status
{
	if (identifier == 1000 && data.length)
	{
		NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		self.entries = [[[json JSONValue] objectForKey:@"response"] objectForKey:@"list"];
		[json release];
		[tableView reloadData];
	}
}

- (void)dataReceived:(NSInteger)identifier withStatus:(NSInteger)status
{
	// MUST be images we need a refesh
	[tableView reloadData];
}

- (void)redirectReceived:(NSInteger)identifier withURL:(NSString*)url
{
}

- (void)errorReceived:(NSInteger)identifier withError:(NSError*)error
{
}

@end
