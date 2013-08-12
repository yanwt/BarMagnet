//
//  AddTorrentViewController.m
//  BarMagnet
//
//  Created by Carlo Tortorella on 15/07/13.
//  Copyright (c) 2013 Carlo Tortorella. All rights reserved.
//

#import "AddTorrentViewController.h"
#import "TorrentDelegate.h"
#import "FileHandler.h"
#import "TorrentClient.h"
#import "SVWebViewController.h"

@implementation AddTorrentViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isEqual:[self textBox]])
	{
		[self addTorrent];
	}
	else if ([textField isEqual:[self searchBox]])
	{
		NSString * query = [[FileHandler sharedInstance] settingsValueForKey:@"query_format"];
		if ([[textField text] length] && [query length])
		{
			if ([query rangeOfString:@"https://"].location != NSNotFound)
			{
				SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[query stringByReplacingOccurrencesOfString:@"%query%" withString:[[textField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
				[[self navigationController] pushViewController:webViewController animated:YES];
			}
			else
			{
				SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[@"http://" stringByAppendingString:[query stringByReplacingOccurrencesOfString:@"%query%" withString:[[textField text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
				[[self navigationController] pushViewController:webViewController animated:YES];
			}
		}
	}
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitle:@"Add Torrent"];
	[[self searchBox] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

- (IBAction)doneButton:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[[[TorrentDelegate sharedInstance] currentlySelectedClient] showNotification:nil];
}

- (IBAction)openSiteButton:(id)sender
{
	NSString * site = [[FileHandler sharedInstance] settingsValueForKey:@"preferred_torrent_site"];
	if ([site length])
	{
		if ([site rangeOfString:@"https://"].location != NSNotFound)
		{
			SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:site];
			[[self navigationController] pushViewController:webViewController animated:YES];
		}
		else
		{
			SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[@"http://" stringByAppendingString:site]];
			[[self navigationController] pushViewController:webViewController animated:YES];
		}
	}
}

- (void)addTorrent
{
	NSString * text = [[self textBox] text];
	if ([text length])
	{
		if ([[text substringWithRange:NSMakeRange(0, 7)] isEqual:@"magnet:"])
		{
			[[TorrentDelegate sharedInstance] handleMagnet:text];
		}
		else
		{
			[[TorrentDelegate sharedInstance] handleTorrentFile:text];
		}
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
