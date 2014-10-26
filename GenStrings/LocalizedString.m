//
//  LocalizedString.m
//  GenStrings
//
//  Created by Rick on 2014-07-17.
//  Copyright (c) 2014 Unified Intents. All rights reserved.
//

#import "LocalizedString.h"

@implementation LocalizedString

+(NSDictionary *)parseString:(NSString *) input{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\/\\* .*? \\*\\/\\n\".*?\" = \".*?\";" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *commentRegex = [NSRegularExpression regularExpressionWithPattern:@"\\/\\* .*? \\*\\/" options:NSRegularExpressionCaseInsensitive error:&error];
        NSRegularExpression *secondLineRegex = [NSRegularExpression regularExpressionWithPattern:@"\n.*?$" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    NSMutableDictionary *output = [NSMutableDictionary new];
    [regex enumerateMatchesInString:input options:0 range:NSMakeRange(0, input.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *match = [input substringWithRange:result.range];
        LocalizedString *localizedString = [[self alloc] init];
        [commentRegex enumerateMatchesInString:match options:0 range:NSMakeRange(0, match.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            localizedString.comment = [match substringWithRange:result.range];
        }];
        [secondLineRegex enumerateMatchesInString:match options:0 range:NSMakeRange(0, match.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSArray *components = [[match substringWithRange:result.range] componentsSeparatedByString:@" = "];
            localizedString.key = [[components objectAtIndex:0] substringFromIndex:1];
            NSString *value = [components objectAtIndex:1];
            localizedString.value = [value substringToIndex:value.length - 1];
        }];
        [output setObject:localizedString forKey:localizedString.key];
    }];
    return output;
}

+(NSString *)renderString:(NSArray *)input{
    NSMutableString *output = [NSMutableString new];
    for (LocalizedString *string in input) {
        if([string.comment isEqualToString:@"\"\""])
            string.comment = @"No comment provided by engineer";
        [output appendFormat:@"\n%@\n%@ = %@;\n", string.comment, string.key, string.value];
    }
    return [NSString stringWithString:output];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ %@ %@", self.key, self.value, self.comment];;
}

-(NSComparisonResult)compare:(LocalizedString *)otherString{
    return [self.key compare:otherString.key];
}

-(BOOL)isEqual:(id)object{
    return [self.key isEqual:object];
}

@end
