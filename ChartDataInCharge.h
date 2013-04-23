/* ChartDataInCharge */

#import <Cocoa/Cocoa.h>
#import "../AnandsAstrology/AAAtlas.h"

typedef enum _AADms {
	AADegrees = 0,
	AAMinutes = 1,
	AASeconds = 2
} AADms;
#define AADaySeconds 24*60*60
#define AAHourSeconds 60*60
#define AAMinuteSeconds 60
#define AASecondSeconds 1
#define AATenthsSeconds 0.1

@interface ChartDataInCharge : NSObject
{
    IBOutlet NSTextView		*textView;
    IBOutlet NSWindow		*window;
	IBOutlet NSTextField	*dateField;
	IBOutlet NSDatePicker	*datePicker;
	IBOutlet NSButton		*instantaneouslySwitch;
	IBOutlet NSPopUpButton	*locationPopup;
	IBOutlet NSMatrix		*houseSystemsMatrix;
	IBOutlet NSTextField	*nameField;
	IBOutlet NSPopUpButton	*namePopup;
	IBOutlet NSMatrix		*firstPlanetMatrix;
	IBOutlet NSMatrix		*secondPlanetMatrix;
	IBOutlet NSMatrix		*aspectMatrix;

	NSArray			*_Signs;
	NSDictionary	*_HouseSystems;
	int				_houseSystemChar;
	NSString		*_location;
	NSNumber		*_locationLatitude;
	NSNumber		*_locationLongitude;
	NSNumber		*_locationAltitude;
	NSTimeZone		*_locationTimezone;
	AAAtlas			*myAtlas;
	NSMutableDictionary	*_savedNames;
	NSString		*_savedNamesPath;
	NSDictionary	*_planetaryPositions;
	NSCalendarDate	*_chartDate;
}
- (IBAction)doChartCalc:(id)sender;
- (IBAction)doItNow:(id)sender;
- (IBAction)changeHouseSystem:(id)sender;
- (IBAction)changeLocation:(id)sender;
- (IBAction)saveName:(id)sender;
- (IBAction)findPerfectedAspects:(id)sender;
- (NSArray *)degreesToDMS: (double)degreesFraction;

@end
