//
//  CCManageAccount.m
//  Nextcloud
//
//  Created by Marino Faggiana on 12/03/15.
//  Copyright (c) 2015 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CCManageAccount.h"
#import "AppDelegate.h"
#import "CCLogin.h"
#import "NCAutoUpload.h"
#import "NCBridgeSwift.h"

#define actionSheetCancellaAccount 1

@interface CCManageAccount ()
{
    AppDelegate *appDelegate;
}
@end

@implementation CCManageAccount

- (void)initializeForm
{
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
        
    NSArray *listAccount = [[NCManageDatabase sharedInstance] getAccounts];
    tableAccount *tableAccount = [[NCManageDatabase sharedInstance] getAccountActive];

    // Section : ACCOUNTS -------------------------------------------
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_accounts_", nil)];
    [form addFormSection:section];
    form.rowNavigationOptions = XLFormRowNavigationOptionNone;
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"pickerAccount" rowType:XLFormRowDescriptorTypePicker];
    row.height = 100;
    if (listAccount.count > 0) {
        row.selectorOptions = listAccount;
        row.value = tableAccount.account;
    } else {
        row.selectorOptions = [[NSArray alloc] initWithObjects:@"", nil];
    }
    
    // Avatar
    NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@-%@.png", [CCUtility getDirectoryUserData], [CCUtility getStringUser:appDelegate.activeUser activeUrl:appDelegate.activeUrl], appDelegate.activeUser];
    
    UIImage *avatar = [UIImage imageWithContentsOfFile:fileNamePath];
    if (avatar) {
        
        avatar = [CCGraphics scaleImage:avatar toSize:CGSizeMake(40, 40) isAspectRation:YES];
        
        CCAvatar *avatarImageView = [[CCAvatar alloc] initWithImage:avatar borderColor:[UIColor lightGrayColor] borderWidth:0.5];
        
        CGSize imageSize = avatarImageView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, UIScreen.mainScreen.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [avatarImageView.layer renderInContext:context];
        avatar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    } else {
        avatar = [UIImage imageNamed:@"avatarBN"];
    }
    
    [row.cellConfig setObject:avatar forKey:@"imageView.image"];
    [section addFormRow:row];

    // Section : MANAGE ACCOUNT -------------------------------------------
    
    if ([NCBrandOptions sharedInstance].disable_manage_account == NO) {
        
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_manage_account_", nil)];
        [form addFormSection:section];
        
        // Brand
        if ([NCBrandOptions sharedInstance].disable_multiaccount == NO) {
            
            // New Account nextcloud
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"addAccount" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_add_account_", nil)];
            row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
            [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
            [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"add"] multiplier:2 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
            [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
            [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
            row.action.formSelector = @selector(addAccount:);
            [section addFormRow:row];
        }
        
        // delete Account
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delAccount" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_delete_account_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIColor redColor] forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"trash"] width:50 height:50 color:[UIColor redColor]] forKey:@"imageView.image"];
        [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
        row.action.formSelector = @selector(deleteAccount:);
        if (listAccount.count == 0) row.disabled = @YES;
        [section addFormRow:row];
    }
    
    // Section : USER INFORMATION -------------------------------------------
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_personal_information_", nil)];
    [form addFormSection:section];
    
    // Full Name
    if ([tableAccount.displayName length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userfullname" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_full_name_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"user"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.displayName;
        [section addFormRow:row];
    }
    
    // Address
    if ([tableAccount.address length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"useraddress" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_address_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"address"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.address;
        [section addFormRow:row];
    }
    
    // City + zip
    if ([tableAccount.city length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"usercity" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_city_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"city"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.city;
        if ([tableAccount.zip length] > 0) {
            row.value = [NSString stringWithFormat:@"%@ %@", row.value, tableAccount.zip];
        }
        [section addFormRow:row];
    }
    
    // Country
    if ([tableAccount.country length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"usercountry" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_country_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"country"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = [[NSLocale systemLocale] displayNameForKey:NSLocaleCountryCode value:tableAccount.country];
        //NSArray *countryCodes = [NSLocale ISOCountryCodes];
        [section addFormRow:row];
    }
    
    // Phone
    if ([tableAccount.phone length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userphone" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_phone_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"phone"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.phone;
        [section addFormRow:row];
    }
    
    // Email
    if ([tableAccount.email length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"useremail" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_email_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"email"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.email;
        [section addFormRow:row];
    }
    
    // Web
    if ([tableAccount.webpage length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userweb" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_web_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"web"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.webpage;
        [section addFormRow:row];
    }
    
    // Twitter
    if ([tableAccount.twitter length] > 0) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"usertwitter" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_twitter_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"twitter"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.twitter;
        [section addFormRow:row];
    }
    
    // Section : THIRT PART -------------------------------------------
    BOOL isHandwerkcloudEnabled = [[NCManageDatabase sharedInstance] getCapabilitiesServerBoolWithAccount:tableAccount.account elements:NCElementsJSON.shared.capabilitiesHWCEnabled exists:false];
    if (isHandwerkcloudEnabled) {

        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_user_job_", nil)];
        [form addFormSection:section];
        
        // Business Type
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userbusinesstype" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_businesstype_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"businesstype"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.businessType;
        [section addFormRow:row];
        
        // Business Size
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userbusinesssize" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_businesssize_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"users"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.businessSize;
        [section addFormRow:row];
        
        // Role
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userrole" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_role_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"role"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        if ([tableAccount.role isEqualToString:@"owner"]) row.value = NSLocalizedString(@"_user_owner_", nil);
        else if ([tableAccount.role isEqualToString:@"employee"]) row.value = NSLocalizedString(@"_user_employee_", nil);
        else if ([tableAccount.role isEqualToString:@"contractor"]) row.value = NSLocalizedString(@"_user_contractor_", nil);
        else row.value = @"";
        [section addFormRow:row];
        
        // Company
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"usercompany" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_user_company_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"company"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.value = tableAccount.company;
        [section addFormRow:row];
    
        if (tableAccount.hcIsTrial) {
        
            section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_trial_", nil)];
            [form addFormSection:section];
            
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"trial" rowType:XLFormRowDescriptorTypeInfo title:NSLocalizedString(@"_trial_expired_day_", nil)];
            row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
            [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
            [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"detailTextLabel.font"];
            [row.cellConfig setObject:[UIColor redColor] forKey:@"textLabel.textColor"];
            [row.cellConfig setObject:[UIColor redColor] forKey:@"detailTextLabel.textColor"];
            [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"timer"] width:50 height:50 color:[UIColor redColor]] forKey:@"imageView.image"];
            NSInteger numberOfDays = tableAccount.hcTrialRemainingSec / (24*3600);
            row.value = [@(numberOfDays) stringValue];
            [section addFormRow:row];
        }
    
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // Edit profile
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"editUserProfile" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_user_editprofile_", nil)];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundCell;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"editUserProfile"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        #if defined(HC)
        row.action.viewControllerClass = [HCEditProfile class];
        #endif
        if (listAccount.count == 0) row.disabled = @YES;
        [section addFormRow:row];
    }
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.form = form;
    
    // Open Login
    if (listAccount.count == 0) {
        [appDelegate openLoginView:self selector:k_intro_login openLoginWeb:false];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"_credentials_", nil);
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // changeTheming
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheming) name:k_notificationCenter_changeTheming object:nil];
    
    [self changeTheming];
}

- (void)changeTheming
{
    [appDelegate changeTheming:self tableView:self.tableView collectionView:nil form:true];
    [self initializeForm];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Delegate ===
#pragma --------------------------------------------------------------------------------------------

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    if ([rowDescriptor.tag isEqualToString:@"pickerAccount"] && oldValue && newValue) {
        
        if (![newValue isEqualToString:oldValue] && ![newValue isEqualToString:@""] && ![newValue isEqualToString:appDelegate.activeAccount]) {
            [self ChangeDefaultAccount:newValue];
        }
        
        if ([newValue isEqualToString:@""]) {
            NSArray *listAccount = [[NCManageDatabase sharedInstance] getAccounts];
            if ([listAccount count] > 0) {
                [self ChangeDefaultAccount:listAccount[0]];
            }
        }
    }
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Add Account ===
#pragma --------------------------------------------------------------------------------------------

- (void)addAccount:(XLFormRowDescriptor *)sender
{
    [self deselectFormRow:sender];
    
    [appDelegate openLoginView:self selector:k_intro_login openLoginWeb:false];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Delete Account  ===
#pragma --------------------------------------------------------------------------------------------

- (void)deleteAccount:(XLFormRowDescriptor *)sender
{
    [self deselectFormRow:sender];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_want_delete_",nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_delete_", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        XLFormPickerCell *pickerAccount = (XLFormPickerCell *)[[self.form formRowWithTag:@"pickerAccount"] cellForFormController:self];
        
        tableAccount *tableAccount = [[NCManageDatabase sharedInstance] getAccountWithPredicate:[NSPredicate predicateWithFormat:@"account == %@", pickerAccount.rowDescriptor.value]];
        NSString *account = tableAccount.account;
        
        if (account) {
            [appDelegate deleteAccount:account wipe:false];
        }
        
        NSArray *listAccount = [[NCManageDatabase sharedInstance] getAccounts];
        if ([listAccount count] > 0) {
            [self ChangeDefaultAccount:listAccount[0]];
        } else {
            [self initializeForm];
        }
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_cancel_", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }]];
    
    alertController.popoverPresentationController.sourceView = self.view;
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:sender];
    alertController.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:indexPath];
        
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Change Default Account ===
#pragma --------------------------------------------------------------------------------------------

- (void)ChangeDefaultAccount:(NSString *)account
{
    tableAccount *tableAccount = [[NCManageDatabase sharedInstance] setAccountActive:account];
    if (tableAccount) {
        
        [appDelegate settingActiveAccount:tableAccount.account activeUrl:tableAccount.url activeUser:tableAccount.user activeUserID:tableAccount.userID activePassword:[CCUtility getPassword:tableAccount.account]];
 
        // Init home
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:k_notificationCenter_initializeMain object:nil userInfo:nil];
    }
    
    [self initializeForm];
}

@end
