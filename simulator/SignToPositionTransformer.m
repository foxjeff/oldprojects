//
//  SignToPositionTransformer.m
//  SimpleAstrology
//
//  Created by Jeff Fox on 6/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SignToPositionTransformer.h"


@implementation SignToPositionTransformer

+ (Class)transformedValueClass;
{
    return [NSString class];
}
+ (BOOL)allowsReverseTransformation;
{
    return NO;   
}
- (id)transformedValue:(id)value;
{
	NSString *sign;
	NSManagedObjectContext *mo = [[NSApp delegate] managedObjectContext];
    [mo willAccessValueForKey:@"sign"];
    sign = [mo primitiveValueForKey:@"sign"];
    [mo didAccessValueForKey:@"sign"];
	if (value == NULL) return NULL;
	NSLog(@"value is %@; sign is %@",value,sign);
    if (sign) {
		return @"foo4"; //[self setValue:@"foo4" forKey:@"position"];
    } else {
		return @"bar4"; //[self setValue:@"bar4" forKey:@"position"];
    }
}
@end
