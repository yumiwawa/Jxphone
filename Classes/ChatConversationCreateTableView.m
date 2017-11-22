//
//  MyTableViewController.m
//  UISearchDisplayController
//
//  Created by Phillip Harris on 4/19/14.
//  Copyright (c) 2014 Phillip Harris. All rights reserved.
//

#import "ChatConversationCreateTableView.h"
#import "UIChatCreateCell.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"

@interface ChatConversationCreateTableView ()

@property(nonatomic, strong) NSMutableDictionary *contacts;
@property(nonatomic, strong) NSDictionary *allContacts;
@end

@implementation ChatConversationCreateTableView

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.allContacts =
		[[NSDictionary alloc] initWithDictionary:LinphoneManager.instance.fastAddressBook.addressBookMap];
	self.contacts = [[NSMutableDictionary alloc] initWithCapacity:_allContacts.count];
	[_searchBar becomeFirstResponder];
	[_searchBar setText:@""];
	[self searchBar:_searchBar textDidChange:_searchBar.text];
	self.tableView.accessibilityIdentifier = @"Suggested addresses";
}

- (void)reloadDataWithFilter:(NSString *)filter {
	[_contacts removeAllObjects];

	[_allContacts enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
	  NSString *address = (NSString *)key;
	  ABRecordRef person = (__bridge ABRecordRef)(value);
	  NSString *name = [FastAddressBook displayNameForContact:person];
	  if ((filter.length == 0) || ([name.lowercaseString containsString:filter.lowercaseString]) ||
		  ([address.lowercaseString containsString:filter.lowercaseString])) {
		  _contacts[address] = name;
	  }

	}];
	// also add current entry, if not listed
	NSString *nsuri = filter.lowercaseString;
	LinphoneAddress *addr = linphone_address_new(nsuri.UTF8String);
	if (addr) {
		char *uri = linphone_address_as_string(addr);
		nsuri = [NSString stringWithUTF8String:uri];
		ms_free(uri);
		linphone_address_destroy(addr);
	}
	if (nsuri.length > 0 && [_contacts valueForKey:nsuri] == nil) {
		_contacts[nsuri] = filter;
	}

	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *kCellId = NSStringFromClass(UIChatCreateCell.class);
	UIChatCreateCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
	if (cell == nil) {
		cell = [[UIChatCreateCell alloc] initWithIdentifier:kCellId];
	}
	cell.displayNameLabel.text = [_contacts.allValues objectAtIndex:indexPath.row];
	cell.addressLabel.text = [_contacts.allKeys objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	LinphoneChatRoom *room = linphone_core_get_chat_room_from_uri(
		LC, ((NSString *)[_contacts.allKeys objectAtIndex:indexPath.row]).UTF8String);
	if (!room) {
		[PhoneMainView.instance popCurrentView];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid address", nil)
														message:@"Please specify the entire SIP address for the chat"
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
	} else {
		ChatConversationView *view = VIEW(ChatConversationView);
		[view setChatRoom:room];
		[PhoneMainView.instance popCurrentView];
		[PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	searchBar.showsCancelButton = (searchText.length > 0);
	[self reloadDataWithFilter:searchText];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:FALSE animated:TRUE];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:(searchBar.text.length > 0) animated:TRUE];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}
@end
