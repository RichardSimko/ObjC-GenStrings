//
//  main.m
//  GenStrings
//
//  Created by Rick on 2014-07-17.
//  Copyright (c) 2014 Unified Intents. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizedString.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        NSString *outputFile = @"Localizable.strings";
        NSError *error;
//Not sure if this works
        NSString *macroName = [NSString stringWithUTF8String:argv[0]];
        NSRegularExpression *fullRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@\\(.*?, .*?, .*?\"\\)", macroName] options:NSRegularExpressionCaseInsensitive error:&error];
        if (error) {
            NSLog(@"%@", error);
            error = nil;
        }
        NSArray *paths = @[], [[NSString stringWithUTF8String:argv[1]]];
        for (NSString *path in paths) {
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
            NSString *filePath;
            NSMutableArray *paths = [NSMutableArray new];
            while (filePath = [enumerator nextObject]) {
                if ([filePath.pathExtension isEqualToString:@"m"]) {
                    [paths addObject:[path stringByAppendingPathComponent:filePath]];
                }
                if ([filePath rangeOfString:@"en.lproj"].location != NSNotFound && [filePath.lastPathComponent isEqualToString:outputFile]) {
                    outputFile = [path stringByAppendingPathComponent:filePath];
                }
            }
            NSString *currentStrings = [NSString stringWithContentsOfFile:outputFile encoding:NSUTF8StringEncoding error:&error];
            NSMutableDictionary *allStrings = [[LocalizedString parseString:currentStrings] mutableCopy];
            NSMutableArray *foundStrings = [NSMutableArray new];
            if (error){
                NSLog(@"%@", error);
                error = nil;
            }
            for (NSString *filePath in paths) {
                NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                if(error){
                    NSLog(@"%@", error);
                    error = nil;
                    continue;
                }
                NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
                for (int i = 0; i < lines.count ; i++) {
                    NSString *line = [lines objectAtIndex:i];
                    [fullRegex enumerateMatchesInString:line options:0 range:NSMakeRange(0, line.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                        NSString *found = [line substringWithRange:result.range];
                        NSArray *components = [found componentsSeparatedByString:@", @"];
                        if(components.count < 3){
                            NSLog(@"Missing tokens");
                            exit(-1);
                        }
                        NSString *key = [[components objectAtIndex:0] substringFromIndex:macroName.length+2];
                        [foundStrings addObject:key];
                        NSString *newDefaultValue = [components objectAtIndex:1];
                        if(![allStrings objectForKey:key]){
                            NSString *comment = [[components objectAtIndex:2] substringWithRange:NSMakeRange(0, ((NSString *)[components objectAtIndex:2]).length-1)];
                            if([comment isEqualToString:@"\"\""])
                                comment = @"No comment provided by engineer";
                            LocalizedString *string = [LocalizedString new];
                            string.key = key;
                            string.comment = [NSString stringWithFormat:@"/* %@ */",comment];
                            string.value = newDefaultValue;
                            [allStrings setObject:string forKey:string.key];
                        } else {
                            NSString *currentValue = ((LocalizedString*)[allStrings objectForKey:key]).value;
                            if (![currentValue isEqualToString:newDefaultValue]) {
                                NSLog(@"WARNING: Conflicting values for key %@:\nOld value: %@\nNew value: %@\n(%@:%d)", key, currentValue, newDefaultValue, filePath.lastPathComponent, i+1);
                            }
                        }
                    }];
                }
            }
            NSMutableString *mutString = [NSMutableString new];
            for (NSString *oldKey in allStrings.allKeys) {
                if (![foundStrings containsObject:oldKey]) {
                    [mutString appendFormat:@"%@\n", oldKey];
                }
            }
            if (mutString.length > 0) {
                [mutString insertString:@"Unused keys:\n" atIndex:0];
                NSLog(@"%@", mutString);
            }
            NSString *output = [LocalizedString renderString:[[allStrings allValues] sortedArrayUsingSelector:@selector(compare:)]];
            [output writeToFile:outputFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error)
                NSLog(@"%@", error);
        }
    }
    return 0;
}

