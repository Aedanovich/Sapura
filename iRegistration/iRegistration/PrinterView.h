//
//  PrinterView.h
//  SDK_Sample_Rj4040
//
//  Created by BIL on 12/09/03.
//
//

#import <Foundation/Foundation.h>
#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>

@interface PrinterView : UIViewController <BRPtouchNetworkDelegate>

{
	IBOutlet    UITableView*    tablePrinterList;		//	Printer List
	
    NSTimer*					tm;						//	Timer
	UIActivityIndicatorView*	indicator;				//	Indicator
	UIView*						loadingView;			//	Indicator view

}

@property (nonatomic, strong) NSArray* aryListData;			//	IPAddress Array

@end
