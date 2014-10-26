//
//  LocalizedString.h
//  GenStrings
//
//  Created by Rick on 2014-07-17.
//  Copyright (c) 2014 Unified Intents. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizedString : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSString *value;

+(NSDictionary *)parseString:(NSString *) input;
+(NSString *)renderString:(NSArray *)input;
-(NSComparisonResult)compare:(LocalizedString *)otherString;
@end
