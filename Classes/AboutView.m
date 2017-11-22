/* AboutViewController.m
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "PhoneMainView.h"
#import "LinphoneManager.h"
#include "linphone/lpconfig.h"
#include "LinphoneIOSVersion.h"

@implementation AboutView

#pragma mark - ViewController Functions

- (void)viewDidLoad {
	[super viewDidLoad];

	UIScrollView *scrollView = (UIScrollView *)self.view;
	[scrollView addSubview:_contentView];
	[scrollView setContentSize:[_contentView bounds].size];

	[_linphoneLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
 
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:nil
															   sideMenu:SideMenuView.class
															 fullscreen:false
														 isLeftFragment:YES
														   fragmentWith:nil];
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark -

+ (void)removeBackground:(UIView *)view {
	for (UIView *subview in [view subviews]) {
		[subview setOpaque:NO];
		[subview setBackgroundColor:[UIColor clearColor]];
	}
	[view setOpaque:NO];
	[view setBackgroundColor:[UIColor clearColor]];
}

+ (UIScrollView *)defaultScrollView:(UIWebView *)webView {
	return webView.scrollView;
}

#pragma mark - Action Functions

- (IBAction)onLinkTap:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_linkLabel.text]];
}

#pragma mark - UIWebViewDelegate Functions

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	CGSize size = [webView sizeThatFits:CGSizeMake(self.view.bounds.size.width, 10000.0f)];
	float diff = size.height - webView.bounds.size.height;

	CGRect contentFrame = [self.view bounds];
	contentFrame.size.height += diff;
	[_contentView setAutoresizesSubviews:FALSE];
	[_contentView setFrame:contentFrame];
	[_contentView setAutoresizesSubviews:TRUE];
	[(UIScrollView *)self.view setContentSize:contentFrame.size];
 
}

- (BOOL)webView:(UIWebView *)inWeb
	shouldStartLoadWithRequest:(NSURLRequest *)inRequest
				navigationType:(UIWebViewNavigationType)inType {
	if (inType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[inRequest URL]];
		return NO;
	}

	return YES;
}

- (IBAction)onDialerBackClick:(id)sender {
	[PhoneMainView.instance popToView:DialerView.compositeViewDescription];
}
@end
