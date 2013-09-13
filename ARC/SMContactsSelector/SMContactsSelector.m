//
//  SMContactsSelector.m
//  
//
//  Created by Sergio on 03/03/11.
//  Copyright 2011 Sergio. All rights reserved.
//

#import "SMContactsSelector.h"
#import "rSkybox.h"

@interface NSArray (Alphabet)

+ (NSArray *)spanishAlphabet;

+ (NSArray *)englishAlphabet;

- (NSMutableArray *)createList;

- (NSArray *)castToArray;

- (NSMutableArray *)castToMutableArray;


@end

@implementation NSArray (Alphabet)

+ (NSArray *)spanishAlphabet
{
    NSArray *letters = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"Ñ", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    NSArray *aux = [NSArray arrayWithArray:letters];
    return aux;    
}

+ (NSArray *)englishAlphabet
{
    NSArray *letters = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    NSArray *aux = [NSArray arrayWithArray:letters];
    return aux;    
}

- (NSMutableArray *)createList
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self];
    [list addObject:@"#"];
    
    NSMutableArray *aux = [NSMutableArray arrayWithArray:list];
    return aux;
}

- (NSArray *)castToArray
{
    if ([self isKindOfClass:[NSMutableArray class]])
    {
        NSArray *a = [[NSArray alloc] initWithArray:self];
        NSArray *aux = [NSArray arrayWithArray:a];
        return aux;
    }
    
    return nil;
}

- (NSMutableArray *)castToMutableArray
{
    if ([self isKindOfClass:[NSArray class]])
    {
        NSMutableArray *a = [[NSMutableArray alloc] initWithArray:self];
        NSMutableArray *aux = [NSMutableArray arrayWithArray:a];
        return aux;
    }
    
    return nil;
}

@end

@interface NSString (character)

- (BOOL)isLetter;

- (BOOL)isRecordInArray:(NSArray *)array;

@end

@implementation NSString (character)

- (BOOL)isLetter
{
	NSArray *letters = [NSArray spanishAlphabet]; //replace by your alphabet
	BOOL isLetter = NO;
	
	for (int i = 0; i < [letters count]; i++)
	{
		if ([[[self substringToIndex:1] uppercaseString] isEqualToString:[letters objectAtIndex:i]]) 
		{
			isLetter = YES;
			break;
		}
	}
	
	return isLetter;
}

- (BOOL)isRecordInArray:(NSArray *)array
{
    for (NSString *str in array)
    {
        if ([self isEqualToString:str]) 
        {
            return YES;
        }
    }
    
    return NO;
}

@end

@interface NSMutableArray (Duplicates)

- (NSMutableArray *)removeDuplicateObjects;

- (NSMutableArray *)removeNullValues;

- (NSMutableArray *)reverse;

@end

@implementation NSMutableArray (Duplicates)

- (NSMutableArray *)reverse
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    
    for (id element in enumerator) 
    {
        [array addObject:element];
    }
    
    return array;
}

- (NSMutableArray *)removeNullValues
{
    NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:self];
    int index = 0;
    
    for (NSDictionary *d in self)
    {
        if ([[d valueForKey:@"name"] containsString:@"null"])
        {
            [removed removeObjectAtIndex:index];
        }
        
        index++;
    }
    
    return removed;
}

- (NSMutableArray *)removeDuplicateObjects
{
    NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:self];
    NSMutableArray *removedTemp = [[[NSMutableArray alloc] initWithArray:self] reverse];
    NSMutableArray *selfTemp = [[[NSMutableArray alloc] initWithArray:self] reverse];

    int index = [removed indexOfObject:[removed lastObject]];
    
    for (NSDictionary *d in selfTemp)
    {
        NSString *t = [NSString stringWithFormat:@"%@", [d valueForKey:@"name"]];
        NSString *str1 = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        int count = 0;
        for (NSDictionary *dict in removedTemp)
        {
            NSString *t = [NSString stringWithFormat:@"%@", [dict valueForKey:@"name"]];
            NSString *str2 = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([str1 isEqualToString:str2])
            {
                count++;
                
                if (count > 1)
                {
                    [removed removeObjectAtIndex:index];
                    index = [removed indexOfObject:[removed lastObject]];
                    removedTemp = nil;
                    removedTemp = [removed reverse];
                    break;
                }
            }
        }

        index--;
    }

    return removed;
}

@end

@implementation SMContactsSelector
@synthesize table;
@synthesize cancelItem;
@synthesize doneItem;
@synthesize delegate;
@synthesize filteredListContent;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize data;
@synthesize barSearch;
@synthesize alertTable;
@synthesize selectedItem;
@synthesize currentTable;
@synthesize arrayLetters;
@synthesize requestData;
@synthesize alertTitle;
@synthesize recordIDs;
@synthesize showModal;
@synthesize toolBar;
@synthesize showCheckButton;
@synthesize upperBar;
@synthesize activity, activityLabel;


-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        [super viewDidLoad];
        self.table.hidden = YES;
        self.activity.hidden = NO;
        self.activityLabel.hidden = NO;
        self.navigationController.navigationBar.hidden = YES;
        if ((requestData != DATA_CONTACT_TELEPHONE) &&
            (requestData != DATA_CONTACT_EMAIL) &&
            (requestData != DATA_CONTACT_ID))
        {
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
            @throw ([NSException exceptionWithName:@"Undefined data request"
                                            reason:@"Define requestData variable (EMAIL or TELEPHONE)"
                                          userInfo:nil]);
        }
        
        NSString *currentLanguage = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] lowercaseString];
        
        // Jetzt Spanisch und Englisch nur
        // Por el momento solo ingles y español
        // At the moment only Spanish and English
        // replace by your alphabet
        if ([currentLanguage isEqualToString:@"es"])
        {
            arrayLetters = [[NSArray spanishAlphabet] createList];
            cancelItem.title = @"Cancelar";
            doneItem.title = @"Hecho";
            alertTitle = @"Selecciona";
        }
        else
        {
            arrayLetters = [[NSArray englishAlphabet] createList];
            cancelItem.title = @"Cancel";
            doneItem.title = @"Save";
            alertTitle = @"Select";
        }
        
        cancelItem.action = @selector(dismiss);
        doneItem.action = @selector(acceptAction);
        
        if (!showModal)
        {
            toolBar.hidden = YES;
            CGRect rect = table.frame;
            rect.size.height += toolBar.frame.size.height;
            table.frame = rect;
            table.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
        
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
        
        if (self.isIos6) {
            __block SMContactsSelector *controller = self;
            
            // Request authorization to Address Book
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
            {
                ABAddressBookRequestAccessWithCompletion(addressBookRef,
                                                         ^(bool granted, CFErrorRef error) {
                                                             if (granted)
                                                                 [controller loadContacts];
                                                             
                                                         });
            }
            else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
            {
                // The user has previously given access, add the contact
                //[self loadContacts];
                [self performSelectorInBackground:@selector(loadContacts) withObject:nil];
                
            }
            else
            {
                NSString *currentLanguage = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] lowercaseString];
                
                NSString *msg = @"";
                
                if ([currentLanguage isEqualToString:@"es"])
                {
                    msg = @"No se tiene permiso para obtener los contactos, por favor, actívelo en Preferencias de la privacidad.";
                }
                else
                {
                    msg = @"Unable to get your contacts, enable it on your privacy preferences.";
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                alert.tag = 457;
                [alert show];
                
                return;
            }
            
        }else{
            [self performSelectorInBackground:@selector(loadContacts) withObject:nil];
            
        }
        
        
        selectedRow = [NSMutableArray new];
        table.editing = NO;
        table.backgroundColor = [UIColor clearColor];

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

   
}

- (void)viewDidLoad
{
	
}

- (void)loadContacts
{
    @autoreleasepool {
        @try {
            NSString *objsAux = @"";
            ABAddressBookRef addressBook = ABAddressBookCreate( );
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            
            CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
            dataArray = [NSMutableArray new];
            
            for (int i = 0; i < nPeople; i++)
            {
                
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                ABMultiValueRef property = ABRecordCopyValue(person, (requestData == DATA_CONTACT_TELEPHONE) ? kABPersonPhoneProperty : kABPersonEmailProperty);
                
                NSArray *propertyArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(property);
                CFRelease(property);
                
                NSString *objs = @"";
                
                BOOL lotsItems = NO;
                for (int i = 0; i < [propertyArray count]; i++)
                {
                    if ([objs isEqualToString:@""])
                    {
                        objs = [propertyArray objectAtIndex:i];
                        objsAux = [objsAux stringByAppendingFormat:@",%@", objs];
                    }
                    else
                    {
                        lotsItems = YES;
                        objs = [objs stringByAppendingString:[NSString stringWithFormat:@",%@", [propertyArray objectAtIndex:i]]];
                        objsAux = [objsAux stringByAppendingFormat:@",%@", objs];
                    }
                }
                
                
                CFStringRef name;
                name = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                CFStringRef lastNameString;
                lastNameString = ABRecordCopyValue(person, kABPersonLastNameProperty);
                CFStringRef emailString;
                emailString = ABRecordCopyValue(person, kABPersonEmailProperty);
                
                NSString *nameString = (__bridge NSString *)name;
                
                NSString *lastName = (__bridge NSString *)lastNameString;
                int currentID = (int)ABRecordGetRecordID(person);
                
                if ((__bridge id)lastNameString != nil)
                {
                    nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastName];
                }
                
                NSMutableDictionary *info = [NSMutableDictionary new];
                [info setValue:[NSString stringWithFormat:@"%@", [[nameString stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:1]] forKey:@"letter"];
                [info setValue:[NSString stringWithFormat:@"%@", nameString] forKey:@"name"];
                [info setValue:@"-1" forKey:@"rowSelected"];
                
                if ((![objs isEqualToString:@""]) || ([[objs lowercaseString] rangeOfString:@"null"].location == NSNotFound))
                {
                    if (requestData == DATA_CONTACT_EMAIL)
                    {
                        [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"email"];
                        
                        if (!lotsItems)
                        {
                            [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"emailSelected"];
                        }
                        else
                        {
                            [info setValue:@"" forKey:@"emailSelected"];
                        }
                    }
                    
                    if (requestData == DATA_CONTACT_TELEPHONE)
                    {
                        [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephone"];
                        
                        if (!lotsItems)
                        {
                            [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephoneSelected"];
                        }
                        else
                        {
                            [info setValue:@"" forKey:@"telephoneSelected"];
                        }
                    }
                    
                    if (requestData == DATA_CONTACT_ID)
                    {
                        [info setValue:[NSString stringWithFormat:@"%d", currentID] forKey:@"recordID"];
                        
                        [info setValue:@"" forKey:@"recordIDSelected"];
                    }
                }
                
                if ([recordIDs count] > 0)
                {
                    BOOL insert = ([[NSString stringWithFormat:@"%d", currentID] isRecordInArray:recordIDs]);
                    
                    if (insert)
                    {
                        [dataArray addObject:info];
                    }
                }
                else
                    [dataArray addObject:info];
                
                if (name) CFRelease(name);
                if (lastNameString) CFRelease(lastNameString);
            }
            
            CFRelease(allPeople);
            CFRelease(addressBook);
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[[NSSet setWithArray:dataArray] allObjects]];
            //        temp = [temp removeNullValues];
            //        temp = [temp removeDuplicateObjects];
            dataArray = nil;
            dataArray = [NSMutableArray arrayWithArray:temp];
            
            //        NSSortDescriptor *sortDescriptor;
            //        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name"
            //                                                      ascending:YES] autorelease];
            //
            //        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            //
            NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES
                                                                    selector:@selector(localizedStandardCompare:)];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
            
            data = [dataArray sortedArrayUsingDescriptors:sortDescriptors];
            
            //NSLog(@"data Not find dup: %@", data);
            
            NSMutableArray *dataTemp = [data mutableCopy];
            
            for (NSDictionary *item in data)
            {
                NSString *str = (NSString *)[item valueForKey:@"telephone"];
                
                if ([str containsString:@","])
                {
                    NSArray *tels = [str componentsSeparatedByString:@","];
                    
                    for (NSString *i in tels)
                    {
                        int count = 0;
                        
                        for (NSDictionary *item in dataTemp)
                        {
                            NSString *str = (NSString *)[item valueForKey:@"telephone"];
                            
                            if ([str containsString:i])
                                count++;
                        }
                        
                        if (count > 1)
                            [dataTemp removeObject:item];
                    }
                }
            }
            
            data = dataTemp;
            
            //NSLog(@"data find dup: %@", data);
            
            if (self.savedSearchTerm)
            {
                [self.searchDisplayController setActive:self.searchWasActive];
                [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
                [self.searchDisplayController.searchBar setText:savedSearchTerm];
                
                self.savedSearchTerm = nil;
            }
            
            self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
            self.searchDisplayController.searchBar.showsCancelButton = NO;
            
            NSMutableDictionary	*info = [NSMutableDictionary new];
            
            for (int i = 0; i < [arrayLetters count]; i++)
            {
                NSMutableArray *array = [NSMutableArray new];
                
                for (NSDictionary *dict in data)
                {
                    NSString *name = [dict valueForKey:@"name"];
                    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                    
                    NSString *email = [dict valueForKey:@"email"];

                    if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:i]])
                    {
                        if ([email length] > 0) {
                            self.didFind = YES;
                            [array addObject:dict];
                        }
                    }
                }
                
                [info setValue:array forKey:[arrayLetters objectAtIndex:i]];
            }
            
            for (int i = 0; i < [arrayLetters count]; i++)
            {
                NSMutableArray *array = [NSMutableArray new];
                
                for (NSDictionary *dict in data)
                {
                    NSString *name = [dict valueForKey:@"name"];
                    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                    
                    NSString *email = [dict valueForKey:@"email"];
                    
          
                    if ((![name isLetter]) && (![name containsNullString]) && ([email length] > 0))
                    {
                        self.didFind = YES;
                        [array addObject:dict];
                    }
                }
                
                [info setValue:array forKey:@"#"];
            }
            
            
            dataArray = [[NSMutableArray alloc] initWithObjects:info, nil];
            NSLog(@"LOGGIN INFO:************************************************************ %@", info);
            
            self.filteredListContent = [NSMutableArray arrayWithCapacity:[data count]];
        }
        @catch (NSException *exception) {
             [rSkybox sendClientLog:@"SMContactSelector.loadContacts" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        }
       
        
        [self performSelectorOnMainThread:@selector(doneContacts) withObject:nil waitUntilDone:NO];
    }
}

-(void)doneContacts{
    
    if (!self.didFind) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Contacts Found" message:@"Only contacts with a valid email address can be invited.  None of your contacts have an email address enetered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    [self.table reloadData];
    self.activity.hidden = YES;
    self.activityLabel.hidden = YES;
    self.table.hidden = NO;
}

- (void)acceptAction
{
	@try {
        NSMutableArray *objects = [NSMutableArray new];
        
        for (int i = 0; i < [arrayLetters count]; i++)
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
            
            for (int x = 0; x < [obj count]; x++)
            {
                NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
                BOOL checked = [[item objectForKey:@"checked"] boolValue];
                
                if (checked)
                {
                    NSString *str = @"";
                    
                    if (requestData == DATA_CONTACT_TELEPHONE)
                    {
                        str = [item valueForKey:@"telephoneSelected"];
                        
                        if (![str isEqualToString:@""])
                        {
                            [objects addObject:str];
                        }
                    }
                    else if (requestData == DATA_CONTACT_EMAIL)
                    {
                        str = [item valueForKey:@"emailSelected"];
                        
                        if (![str isEqualToString:@""])
                        {
                            [objects addObject:str];
                        }
                    }
                    else
                    {
                        str = [item valueForKey:@"recordID"];
                        
                        if (![str isEqualToString:@""])
                        {
                            [objects addObject:str];
                        }
                    }
                }
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)]) 
            [self.delegate numberOfRowsSelected:[objects count] withData:objects andDataType:requestData];
        
        
        [self dismiss];
    }
    @catch (NSException *exception) {
           [rSkybox sendClientLog:@"SMContactSelector.acceptAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}

- (void)dismiss
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@try {
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else
        {
            [self tableView:self.table accessoryButtonTappedForRowWithIndexPath:indexPath];
            [self.table deselectRowAtIndexPath:indexPath animated:YES];
        }
    
    }
    @catch (NSException *exception) {
         [rSkybox sendClientLog:@"SMContactSelector.didSelectRowAtIndexPath" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	@try {
        static NSString *kCustomCellID = @"MyCellID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        NSMutableDictionary *item = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            item = (NSMutableDictionary *)[self.filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
            
            item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];
        }
        
        cell.textLabel.text = [item objectForKey:@"name"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
        [item setObject:cell forKey:@"cell"];
        
        BOOL checked = [[item objectForKey:@"checked"] boolValue];
        UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (!showCheckButton)
            button.hidden = YES;
        else
            button.hidden = NO;
        
        CGRect frame = CGRectMake(0.0, 0.0, 28, 28);
        button.frame = frame;
        
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            button.userInteractionEnabled = NO;
        }
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        return cell;
    }
    @catch (NSException *exception) {
        
        [rSkybox sendClientLog:@"SMContactSelector.cellForRowAtIndexPath" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return [[UITableViewCell alloc] init];
    }
  
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	@try {
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:self.table];
        NSIndexPath *indexPath = [self.table indexPathForRowAtPoint: currentTouchPosition];
        
        if (indexPath != nil)
        {
            [self tableView: self.table accessoryButtonTappedForRowWithIndexPath: indexPath];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.checkButtonTapped" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
   
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	

	@try {
        NSMutableDictionary *item = nil;
        
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            item = (NSMutableDictionary *)[filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
            item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];
        }
        
        NSArray *objectsArray = nil;
        
        if (requestData == DATA_CONTACT_TELEPHONE)
            objectsArray = (NSArray *)[[item valueForKey:@"telephone"] componentsSeparatedByString:@","];
        else if (requestData == DATA_CONTACT_EMAIL)
            objectsArray = (NSArray *)[[item valueForKey:@"email"] componentsSeparatedByString:@","];
        else
            objectsArray = (NSArray *)[[item valueForKey:@"recordID"] componentsSeparatedByString:@","];
        
        int objectsCount = [objectsArray count];
        
        if (objectsCount > 1)
        {
            selectedItem = item;
            self.currentTable = tableView;
            
            alertTable = [[AlertTableView alloc] initWithCaller:self
                                                           data:objectsArray
                                                          title:alertTitle
                                                        context:self
                                                     dictionary:item
                                                        section:indexPath.section
                                                            row:indexPath.row];
            alertTable.isModal = showModal;
            [alertTable show];
        }
        else
        {
            
            if (showModal)
            {
                BOOL checked = [[item objectForKey:@"checked"] boolValue];
                
                [item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
                
                UITableViewCell *cell = [item objectForKey:@"cell"];
                UIButton *button = (UIButton *)cell.accessoryView;
                
                UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
                [button setBackgroundImage:newImage forState:UIControlStateNormal];
                
                if (tableView == self.searchDisplayController.searchResultsTableView)
                {
                    [self.searchDisplayController.searchResultsTableView reloadData];
                    [selectedRow addObject:item];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)])
                {
                    [self.delegate numberOfRowsSelected:1 
                                               withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                            andDataType:requestData];
                }
            }
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.acccessoryButtonTappedForRowWithPath" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}

#pragma mark
#pragma mark AlertTableViewDelegate delegate method

- (void)didSelectRowAtIndex:(NSInteger)row 
                    section:(NSInteger)section
                withContext:(id)context
                       text:(NSString *)text 
                    andItem:(NSMutableDictionary *)item
                        row:(int)rowSelected
{
    @try {
        if ([text isEqualToString:@"-1"])
        {
            selectedItem = nil;
            return;
        }
        else if ([text isEqualToString:@"-2"])
        {
            (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:@"" forKey:@"telephoneSelected"] : [selectedItem setValue:@"" forKey:@"emailSelected"];
            [selectedItem setObject:[NSNumber numberWithBool:NO] forKey:@"checked"];
            [selectedItem setValue:@"-1" forKey:@"rowSelected"];
            UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
            UIButton *button = (UIButton *)cell.accessoryView;
            
            UIImage *newImage = [UIImage imageNamed:@"unchecked.png"];
            [button setBackgroundImage:newImage forState:UIControlStateNormal];
        }
        else
        {
            (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:text forKey:@"telephoneSelected"] : [selectedItem setValue:text forKey:@"emailSelected"];
            [selectedItem setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
            
            UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
            UIButton *button = (UIButton *)cell.accessoryView;
            
            UIImage *newImage = [UIImage imageNamed:@"checked.png"];
            [button setBackgroundImage:newImage forState:UIControlStateNormal];
            
            if (self.currentTable == self.searchDisplayController.searchResultsTableView)
            {
                [self.searchDisplayController.searchResultsTableView reloadData];
                [selectedRow addObject:selectedItem];
            }
        }
        
        if (self.currentTable == self.searchDisplayController.searchResultsTableView)
        {
            [filteredListContent replaceObjectAtIndex:rowSelected withObject:item];
        }
        else
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:section]];
            [obj replaceObjectAtIndex:rowSelected withObject:item];
        }
        
        selectedItem = nil;
        
        if (!showModal)
        {
            if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)])
            {
                [self.delegate numberOfRowsSelected:1
                                           withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                        andDataType:requestData];
            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.didSelectRowSectionWithContext" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	@try {
        if (tableView == self.searchDisplayController.searchResultsTableView)
            return [self.filteredListContent count];
        
        int i = 0;
        NSString *sectionString = [arrayLetters objectAtIndex:section];
        
        NSArray *array = (NSArray *)[[dataArray objectAtIndex:0] valueForKey:sectionString];
        
        for (NSDictionary *dict in array)
        {
            NSString *name = [dict valueForKey:@"name"];
            name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (![name isLetter])
            {
                i++;
            }
            else
            {
                if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:section]]) 
                {
                    i++;
                }
            }
        }
        
        return i;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.numberOfRowsInSection" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return 0;
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return nil;
    }
	
    return arrayLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 0;
    }
	
    return [arrayLetters indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
	
	return [arrayLetters count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{	
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return @"";
    }
	
	return [arrayLetters objectAtIndex:section];
}

#pragma mark -
#pragma mark Content Filtering

- (void)displayChanges:(BOOL)yesOrNO
{
	@try {
        int elements = [filteredListContent count];
        NSMutableArray *selected = [NSMutableArray new];
        for (int i = 0; i < elements; i++)
        {
            NSMutableDictionary *item = (NSMutableDictionary *)[filteredListContent objectAtIndex:i];
            
            BOOL checked = [[item objectForKey:@"checked"] boolValue];
            
            if (checked)
            {
                [selected addObject:item];
            }
        }
        
        for (int i = 0; i < [arrayLetters count]; i++)
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
            
            for (int x = 0; x < [obj count]; x++)
            {
                NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
                
                if (yesOrNO)
                {
                    for (NSDictionary *d in selected)
                    {
                        if (d == item)
                        {
                            [item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
                        }
                    }
                }
                else 
                {
                    for (NSDictionary *d in selectedRow)
                    {
                        if (d == item)
                        {
                            [item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.displayChanges" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

	
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	selectedRow = [NSMutableArray new];
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	selectedRow = nil;
	[self displayChanges:NO];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self displayChanges:YES];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString*)scope
{
	@try {
        [self.filteredListContent removeAllObjects];
        
        for (int i = 0; i < [arrayLetters count]; i++)
        {
            NSMutableArray *obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
            
            for (int x = 0; x < [obj count]; x++)
            {
                NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
                
                NSString *name = [[item valueForKey:@"name"] lowercaseString];
                name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                NSComparisonResult result = [name compare:[searchText lowercaseString] options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
                if (result == NSOrderedSame)
                {
                    [self.filteredListContent addObject:item];
                }
            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SMContactSelector.filterContentForSearchText" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}



@end