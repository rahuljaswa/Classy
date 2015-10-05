//
//  RJAuthenticationDetailsViewController.m
//  NINEXX
//
//  Created by Rahul Jaswa on 6/10/15.
//  Copyright (c) 2015 Rahul Jaswa. All rights reserved.
//

#import "RJAuthenticationDetailsViewController.h"
#import "RJStyleManager.h"
#import "RJTextFieldTableViewCell.h"
#import "UIImage+RJAdditions.h"
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kTextFieldCellID = @"TextFieldCellID";
static NSString *const kCellID = @"CellID";

typedef NS_ENUM(NSInteger, Section) {
    kSectionInputs,
    kSectionDone,
    kNumSections
};

typedef NS_ENUM(NSInteger, InputsSectionRow) {
    kInputsSectionRowEmail,
    kInputsSectionRowName,
    kNumInputsSectionRows
};


@interface RJAuthenticationDetailsViewController () <UITextFieldDelegate>

@end


@implementation RJAuthenticationDetailsViewController

#pragma mark - Public Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Section authenticationSection = section;
    switch (authenticationSection) {
        case kSectionInputs:
            return kNumInputsSectionRows;
            break;
        case kSectionDone:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    Section authenticationSection = indexPath.section;
    switch (authenticationSection) {
        case kSectionInputs: {
            RJTextFieldTableViewCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellID forIndexPath:indexPath];
            
            InputsSectionRow inputRow = indexPath.row;
            switch (inputRow) {
                case kInputsSectionRowEmail: {
                    textFieldCell.textField.text = self.email;
                    textFieldCell.textField.placeholder = NSLocalizedString(@"Email", nil);
                    textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    textFieldCell.textField.tag = kInputsSectionRowEmail;
                    textFieldCell.textField.delegate = self;
                    break;
                }
                case kInputsSectionRowName: {
                    textFieldCell.textField.text = self.name;
                    textFieldCell.textField.placeholder = NSLocalizedString(@"Profile Name", nil);
                    textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    textFieldCell.textField.tag = kInputsSectionRowName;
                    textFieldCell.textField.delegate = self;
                    break;
                }
                default:
                    break;
            }
            
            cell = textFieldCell;
            break;
        }
        case kSectionDone: {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Save Profile Information", nil);
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - Public Protocols - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionDone) {
        if (![self validateEmail:self.email]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Email is invalid", nil)];
        } else if ([self.name length] < 4) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Name must be 4 characters or more", nil)];
        } else {
            [self.delegate authenticationDetailsViewControllerDidFinish:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Protocols - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == kInputsSectionRowEmail) {
        self.email = newString;
    } else if (textField.tag == kInputsSectionRowName) {
        self.name = newString;
    }
    return YES;
}

#pragma mark - Private Instance Methods

- (void)cancelButtonPressed:(UIButton *)button {
    [self.delegate authenticationDetailsViewControllerDidCancel:self];
}

- (BOOL)validateEmail:(NSString *)email {
    if ([email length] == 0) {
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Public Instance Methods

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    [self.tableView registerClass:[RJTextFieldTableViewCell class] forCellReuseIdentifier:kTextFieldCellID];
    
    self.tableView.backgroundColor = [[RJStyleManager sharedInstance] themeBackgroundColor];
    
    UIImage *cancelImage = [UIImage tintableImageNamed:@"cancelButton"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cancelImage
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonPressed:)];
}

@end

