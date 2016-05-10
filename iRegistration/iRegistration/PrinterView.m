//
//  PrinterView.m
//  SDK_Sample_Rj4040
//
//  Created by BIL on 12/09/03.
//
//

#import "PrinterView.h"

@implementation PrinterView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
	UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(pushDone:)];
	self.navigationItem.rightBarButtonItem = btn;
    
    return self;
}

-(void)dealloc
{
}

////////////////////////////////////////////////////////////
//	click on Done
////////////////////////////////////////////////////////////
-(void)pushDone:(id)sender
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.title = @"Printer List";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////////
//
//	TableView
//
//
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
//	Set section count
////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

////////////////////////////////////////////////////////////
//	Set section title
////////////////////////////////////////////////////////////
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	if(0 == section){
		return @"Printer";
	}
	return nil;
}

////////////////////////////////////////////////////////////
//	Set cells count
////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_aryListData count];
}

////////////////////////////////////////////////////////////
//	cell creation
////////////////////////////////////////////////////////////
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell*	cell;
	
	cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if(!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
	}
    
	//	Display Device Information
	BRPtouchNetworkInfo* bpni = [_aryListData objectAtIndex:indexPath.row];
	cell.textLabel.text = bpni.strModelName;
	cell.detailTextLabel.text = bpni.strIPAddress;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

////////////////////////////////////////////////////////////
//	cell selection
////////////////////////////////////////////////////////////
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	//	Cancel selected mode
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	//	check on selected cell
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];

	//	Refer to BRPtouchNetworkInfo
	BRPtouchNetworkInfo* bpni = [_aryListData objectAtIndex:[indexPath row]];

	//	Save IP Address
    [printSetting setObject:bpni.strIPAddress forKey:@"ipAddress"];
    [printSetting setObject:bpni.strModelName forKey:@"LastSelectedPrinter"];
    [printSetting synchronize];

	return;
}


/////////////////////////////////////////
// Error handling code
- (void)handleError:(NSNumber *)error
{
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
    // Handle error here
}

@end
