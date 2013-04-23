//
//  ChartDataInCharge.m
//  Chart Data
//
//  Created by Jeff Fox on 7/5/05.
//  Copyright 2005 Astrology. All rights reserved.
//

#import "ChartDataInCharge.h"

#import "../SwissEphemeris/SWEPlanetPositions.h"
#import "../SwissEphemeris/SWEStarPositions.h"
#import "../SwissEphemeris/SWEHouses.h"

@implementation ChartDataInCharge
- (id)init{
	if (self = [super init]) {
		NSString *signsPath = [[NSBundle mainBundle] pathForResource:@"Signs" ofType:@"plist"];
		_Signs = [[NSArray arrayWithContentsOfFile:signsPath] retain];
		NSString *houseSystemsPath = [[NSBundle mainBundle] pathForResource:@"House Systems" ofType:@"plist"];
		_HouseSystems = [[NSDictionary dictionaryWithContentsOfFile:houseSystemsPath] retain];
		myAtlas = [[AAAtlas alloc] init];
		[SWEPlanetPositions SetSWEPath];
		_savedNamesPath = [[[NSBundle mainBundle] pathForResource:@"Chart Data Names" ofType:@"plist"] retain];
		_savedNames = [[NSMutableDictionary dictionaryWithContentsOfFile:_savedNamesPath] retain];
	}
	return self;
}
- (void)awakeFromNib {
// get locations from AAAtlas and fill a popup
	[locationPopup addItemsWithTitles:[myAtlas knownLocations]];
	[locationPopup removeItemAtIndex:0];
	[locationPopup setTitle:@"Dallas"];
	[self changeLocation:self];
	
	[namePopup addItemsWithTitles:[_savedNames allKeys]];
	[namePopup removeItemAtIndex:0];
	[[firstPlanetMatrix cellAtRow:0 column:0]setTitle:SWESaturn];
	[[secondPlanetMatrix cellAtRow:0 column:0]setTitle:SWESaturn];
	[[firstPlanetMatrix cellAtRow:1 column:0]setTitle:SWEJupiter];
	[[secondPlanetMatrix cellAtRow:1 column:0]setTitle:SWEJupiter];
	[[firstPlanetMatrix cellAtRow:2 column:0]setTitle:SWEMars];
	[[secondPlanetMatrix cellAtRow:2 column:0]setTitle:SWEMars];
	[[firstPlanetMatrix cellAtRow:3 column:0]setTitle:SWESun];
	[[secondPlanetMatrix cellAtRow:3 column:0]setTitle:SWESun];
	[[firstPlanetMatrix cellAtRow:4 column:0]setTitle:SWEVenus];
	[[secondPlanetMatrix cellAtRow:4 column:0]setTitle:SWEVenus];
	[[firstPlanetMatrix cellAtRow:5 column:0]setTitle:SWEMercury];
	[[secondPlanetMatrix cellAtRow:5 column:0]setTitle:SWEMercury];
	[[firstPlanetMatrix cellAtRow:6 column:0]setTitle:SWEMoon];
	[[secondPlanetMatrix cellAtRow:6 column:0]setTitle:SWEMoon];

/*	for filling the radio matrix with all house names
	NSArray *houseNames = [_HouseSystems allKeys];
	NSEnumerator *housesEnumerator = [houseNames objectEnumerator];
	id anObj;
	int matrixRowCount;
	while (anObj = [housesEnumerator nextObject]) {
		if (![anObj isEqualToString:@"Regimontanus"] && ![anObj isEqualToString:@"Placidus"]) {
			[houseSystemsMatrix addRow];
			matrixRowCount = [houseSystemsMatrix numberOfRows];
			[[houseSystemsMatrix cellAtRow:matrixRowCount-1 column:0] setTitle:anObj];
		}
	}
	[houseSystemsMatrix sizeToCells];
*/
	_houseSystemChar = [[_HouseSystems objectForKey:@"Regiomontanus"] intValue]; //'R';//default is Regiomontanus
}
- (NSArray *)degreesToDMS: (double)degreesFraction {
	int degrees = (int)degreesFraction;
	double minutesFraction = (degreesFraction - degrees) *60.0;
	int minutes = (int)minutesFraction;
	double secondsFraction = (minutesFraction - minutes) *60.0;
	int seconds = (int)secondsFraction;
	if (secondsFraction - seconds >= 0.5) seconds += 1;
	if (seconds == 60) {
		seconds = 0;
		minutes += 1;
	}
	if (minutes == 60) {
		if ((degrees+1) % 30 == 0) {	// don't change sign b/c of rounding
			minutes = 59;
			seconds = 59;
		} else {
			minutes = 0;
			degrees += 1;
		}
	}
	return ([NSArray arrayWithObjects:[NSNumber numberWithInt:degrees],
										[NSNumber numberWithInt:minutes],
										[NSNumber numberWithInt:seconds],nil]);
}
- (NSString *)degreesToDMSnice:(double)degreesFraction {
	NSArray *myArray = [self degreesToDMS:degreesFraction];
	int signIndex = (int)([[myArray objectAtIndex:0] intValue]/30.0);
	return [NSString stringWithFormat:@"%d.%d.%d %@",
						[[myArray objectAtIndex:AADegrees] intValue] - signIndex*30,
						[[myArray objectAtIndex:AAMinutes] intValue],
						[[myArray objectAtIndex:AASeconds] intValue],
						[_Signs objectAtIndex:signIndex]];
}
- (IBAction)saveName:(id)sender {
//	NSLog(@"name: %@",[sender stringValue]);
	[_savedNames setObject: [NSDictionary dictionaryWithObjectsAndKeys:
								[datePicker dateValue],@"date",
								_location,@"location",
								[[houseSystemsMatrix selectedCell] title],@"house system",NULL]
					forKey:[nameField stringValue]];
	[namePopup addItemWithTitle:[sender stringValue]];
	[_savedNames writeToFile:_savedNamesPath atomically:YES];
}
- (IBAction)selectName:(id)sender {
	NSString *aName = [namePopup titleOfSelectedItem];
	NSDictionary *stuff = [_savedNames objectForKey:aName];
	[datePicker setDateValue:[stuff objectForKey:@"date"]];
	[locationPopup selectItemWithTitle:[stuff objectForKey:@"location"]];
	int tag;
	if ([[stuff objectForKey:@"house system"] isEqualToString:@"Regiomontanus"]) tag = 0; else tag = 1;
	[houseSystemsMatrix selectCellWithTag:tag];
	[self changeLocation:self];
	[self changeHouseSystem:self];
}
- (IBAction)doItNow:(id)sender {
	[datePicker setDateValue:[NSDate date]];
	[self doChartCalc:self];
}
- (IBAction)changeHouseSystem:(id)sender {
	NSString *newHouseSystem = [[houseSystemsMatrix selectedCell] title];
	_houseSystemChar = [[_HouseSystems objectForKey:newHouseSystem] intValue];
	[self doChartCalc:self];
}
- (IBAction)changeLocation:(id)sender {
	//get _location from location popup
	//change tz for datepicker
	_location = [locationPopup titleOfSelectedItem];
	NSDictionary * locationAttributes = [myAtlas attributesForPlace:_location];
	_locationLatitude = [[locationAttributes objectForKey:@"latitude"] retain];
	_locationLongitude = [[locationAttributes objectForKey:@"longitude"] retain];
	_locationAltitude = [[locationAttributes objectForKey:@"altitude"] retain];
	_locationTimezone = [[NSTimeZone timeZoneWithName:[locationAttributes objectForKey:@"timezone"]] retain];
	[datePicker setTimeZone:_locationTimezone];
	[dateField setStringValue:[_locationTimezone description]];
}
- (IBAction)doChartCalc:(id)sender {
// use _location to get the correct timezone and coordinates
	NSDate *someDate = [datePicker dateValue];
	NSCalendarDate *myDate = [someDate dateWithCalendarFormat:nil timeZone:_locationTimezone];
	NSString *myDateString = [myDate descriptionWithCalendarFormat:@"%A, %B %d, %Y %I:%M:%S %p (%z)\n"];
	[dateField setStringValue:myDateString];
// change the timezone to UTC
	[myDate setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	_chartDate = [myDate copy];
	
	NSMutableString *myString = [NSMutableString stringWithCapacity:200];
	NSDictionary * redAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSColor redColor],NSForegroundColorAttributeName,
//								[NSColor lightGrayColor],NSBackgroundColorAttributeName,
								NULL];
	NSDictionary * blueAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSColor blueColor],NSForegroundColorAttributeName,
								NULL];
	NSAttributedString *ss = [[NSAttributedString alloc]
								initWithString:myDateString attributes:redAttrs];
	[textView insertText:ss];
//	planets:
	[_planetaryPositions release];
	_planetaryPositions = [[SWEPlanetPositions AllPlanetaryPositions:myDate]retain];
	[myString appendFormat:@"Saturn\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWESaturn] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Jupiter\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWEJupiter] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Mars\t\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWEMars] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Sun\t\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWESun] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Venus\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWEVenus] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Mercury\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWEMercury] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"Moon\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWEMoon] objectForKey:SWELongitude]doubleValue]]];
	[myString appendFormat:@"N. Node\t%@\n",
		[self degreesToDMSnice:[[[_planetaryPositions objectForKey:SWENNode] objectForKey:SWELongitude]doubleValue]]];
	

//	fixed stars:
	NSDictionary *stars = [SWEStarPositions HoraryStarPositions:myDate];
	[myString appendFormat:@"\nFixed Stars:\nRegulus\t%@",
		[self degreesToDMSnice:[[stars objectForKey:SWERegulus] doubleValue]]];
	[myString appendFormat:@"\nSirius\t%@",[self degreesToDMSnice:[[stars objectForKey:SWESirius] doubleValue]]];
	[myString appendFormat:@"\nSpica\t%@",[self degreesToDMSnice:[[stars objectForKey:SWESpica] doubleValue]]];
//	[myString appendFormat:@"\nZubenelgenubi\t%@",[self degreesToDMSnice:[[stars objectForKey:SWERegulus] doubleValue]]];

//	house cusps:
	NSDictionary *houses = [SWEHouses HouseLongitudes:myDate
								houseSystem:_houseSystemChar
								latitude:_locationLatitude
								longitude:_locationLongitude];
	[myString appendFormat:@"\nHouse Cusps:\nASC\t\t%@\n",
		[self degreesToDMSnice:[[houses objectForKey:SWEAscendant] doubleValue]]];
	[myString appendFormat:@"MC\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWEMC] doubleValue]]];
	[myString appendFormat:@"2nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE2ndCusp] doubleValue]]];
	[myString appendFormat:@"3nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE3rdCusp] doubleValue]]];
	[myString appendFormat:@"4nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE4thCusp] doubleValue]]];
	[myString appendFormat:@"5nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE5thCusp] doubleValue]]];
	[myString appendFormat:@"6nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE6thCusp] doubleValue]]];
	[myString appendFormat:@"7nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE7thCusp] doubleValue]]];
	[myString appendFormat:@"8nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE8thCusp] doubleValue]]];
	[myString appendFormat:@"9nd\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE9thCusp] doubleValue]]];
	[myString appendFormat:@"10th\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE10thCusp] doubleValue]]];
	[myString appendFormat:@"11th\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE11thCusp] doubleValue]]];
	[myString appendFormat:@"12th\t\t%@\n",[self degreesToDMSnice:[[houses objectForKey:SWE12thCusp] doubleValue]]];

	NSAttributedString *ss2 = [[NSAttributedString alloc]
								initWithString:myString attributes:blueAttrs];
	[textView insertText:ss2];
/*	NSRange newRange = NSMakeRange(ssRange.location,[myString length]);
	[textView setSelectedRange:newRange];
	[textView setSelectedTextAttributes:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor blueColor],NSForegroundColorAttributeName,
			NULL]];
*/
}
- (IBAction)findPerfectedAspects:(id)sender {
	NSString *planetA = [[firstPlanetMatrix selectedCell]title];
	NSString *planetB = [[secondPlanetMatrix selectedCell]title];
	NSString *aspect = [[aspectMatrix selectedCell]title];
	double baseDelta;
	if ([aspect isEqualToString:@"Conjunction"]) baseDelta = 0.0;
	if ([aspect isEqualToString:@"Sextile"]) baseDelta = 60.0;
	if ([aspect isEqualToString:@"Trine"]) baseDelta = 120.0;
	if ([aspect isEqualToString:@"Square"]) baseDelta = 90.0;
	if ([aspect isEqualToString:@"Opposition"]) baseDelta = 180.0;
	double targetDelta = baseDelta + 0.00001;
	double planetALong = [[[_planetaryPositions objectForKey:planetA] objectForKey:SWELongitude]doubleValue];
	double planetBLong = [[[_planetaryPositions objectForKey:planetB] objectForKey:SWELongitude]doubleValue];
	double planetASpeed = [[[_planetaryPositions objectForKey:planetA] objectForKey:SWELongitudeSpeed]doubleValue];
//	double planetBSpeed = [[[_planetaryPositions objectForKey:planetB] objectForKey:SWELongitudeSpeed]doubleValue];
	double startingDelta = planetBLong - planetALong;
	
	NSCalendarDate *nextDate;
	NSDictionary *planetADict;
	NSDictionary *planetBDict;
	int currentInterval = AADaySeconds;
	if (planetASpeed > startingDelta) {
		currentInterval = AAHourSeconds;
		if (planetASpeed/24.0 > startingDelta) {
			currentInterval = AAMinuteSeconds;
			if (planetASpeed/(24.0*60.0) > startingDelta) {
				currentInterval = AASecondSeconds;
				if (planetASpeed/(24.0*60.0*60.0) > startingDelta) {
					currentInterval = AATenthsSeconds;
				}
			}
		}
	}
	nextDate = [_chartDate addTimeInterval:currentInterval];
	planetADict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetA];
	planetBDict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetB];
	double aDelta = [[planetBDict objectForKey:SWELongitude]doubleValue] - [[planetADict objectForKey:SWELongitude]doubleValue];

	while (aDelta > baseDelta && aDelta < startingDelta) {
//		NSLog(@"\ndate is %@\ninterval is: %i\ndelta is %f",nextDate,currentInterval,aDelta);
		nextDate = [nextDate addTimeInterval:currentInterval];
		planetADict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetA];
		planetBDict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetB];
		aDelta = [[planetBDict objectForKey:SWELongitude]doubleValue] - [[planetADict objectForKey:SWELongitude]doubleValue];
		if (aDelta < targetDelta && aDelta >= baseDelta) break;
		else {
			if (aDelta < baseDelta) {
				switch (currentInterval) {
					case AADaySeconds:
//						aDelta = 0;
						nextDate = [nextDate addTimeInterval:-currentInterval+AAHourSeconds];
						currentInterval = AAHourSeconds;
						break;
					case AAHourSeconds:
//						aDelta = 0;
						nextDate = [nextDate addTimeInterval:-currentInterval+AAMinuteSeconds];
						currentInterval = AAMinuteSeconds;
						break;
					case AAMinuteSeconds:
//						aDelta = 0;
						nextDate = [nextDate addTimeInterval:-currentInterval+AASecondSeconds];
						currentInterval = AASecondSeconds;
						break;
//					case AASecondSeconds:
//						aDelta = 0;
//						nextDate = [nextDate addTimeInterval:-currentInterval+AATenthsSeconds];
//						currentInterval = AATenthsSeconds;
//						break;
				}//switch
				NSLog(@"\ndate is %@\ninterval is: %i\ndelta is %f",nextDate,currentInterval,aDelta);
				planetADict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetA];
				planetBDict = [SWEPlanetPositions PlanetPosition:nextDate withString:planetB];
				aDelta = [[planetBDict objectForKey:SWELongitude]doubleValue] - [[planetADict objectForKey:SWELongitude]doubleValue];
			}//second if
		}//else
	}//while
	[nextDate setTimeZone:_locationTimezone];
	NSLog(@"delta is: %f\n\%@: %@\n%@: %@\ndate: %@",
		aDelta,
		planetB,[self degreesToDMSnice:[[planetBDict objectForKey:SWELongitude]doubleValue]],
		planetA,[self degreesToDMSnice:[[planetADict objectForKey:SWELongitude]doubleValue]],
		nextDate);

}
// app delegate stuff:
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	int reply = NSTerminateNow;
    swe_close();
    return reply;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end
/*
 *             hsy = letter code for house system;         
 *                   A  equal                         
 *                   E  equal                         
 *                   C  Campanus                        
 *                   H  horizon / azimut
 *                   K  Koch                             
 *                   O  Porphyry                          
 *                   P  Placidus                          
 *                   R  Regiomontanus                  
 *                   V  equal Vehlow                 
 *                   X  axial rotation system/ Meridian houses 
 *                   G  36 Gauquelin sectors
*/
/*  for loading the house systems plist:
		NSDictionary *hs = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:'R'],@"Regiomontanus",
			[NSNumber numberWithInt:'G'],@"36 Gauguelin Sectors",
			[NSNumber numberWithInt:'X'],@"Meridian",
			[NSNumber numberWithInt:'C'],@"Campanus",
			[NSNumber numberWithInt:'A'],@"Equal",
			[NSNumber numberWithInt:'H'],@"Horizon/Azimut",
			[NSNumber numberWithInt:'K'],@"Koch",
			[NSNumber numberWithInt:'P'],@"Placidus",
			[NSNumber numberWithInt:'O'],@"Porphyry",
			[NSNumber numberWithInt:'V'],@"Vehlow Equal",
			NULL];
		[hs writeToFile:@"/Users/jeff/Projects/Astrology/House Systems new.plist" atomically:YES];
*/
