//
//  NSObject+Additions.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/12.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "NSObject+Additions.h"
#import <objc/runtime.h>

@implementation NSObject (Additions)

- (NSArray*)generatePropertyKeys {
    NSMutableArray* mPropertyArray = [NSMutableArray array];
    
    id currentClass = [self class];
    while (![NSStringFromClass(currentClass) isEqualToString:@"NSObject"]) {
        /// && ([NSBundle bundleForClass:currentClass] == [NSBundle mainBundle])
        unsigned int propertieCount = 0;
        objc_property_t* properties  = class_copyPropertyList(currentClass, &propertieCount);
        
        @autoreleasepool {
            for (int i = 0; i < propertieCount; i++) {
                objc_property_t property = properties[i];
                const char* name = property_getName(property);
                
                NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
                [mPropertyArray addObject:propertyName];
            }
        }
        
        if (properties) {
            free(properties);
        }
        currentClass = [currentClass superclass];
    }
    return mPropertyArray ;
}

- (NSArray*)generatePropertyTypes {
    NSMutableArray* mPropertyTypesArray = [NSMutableArray array];
    
    id currentClass = [self class];
    while (![NSStringFromClass(currentClass) isEqualToString:@"NSObject"]) {
        /// && ([NSBundle bundleForClass:currentClass] == [NSBundle mainBundle])
        unsigned int propertieCount = 0;
        objc_property_t* properties  = class_copyPropertyList(currentClass, &propertieCount);
        
        @autoreleasepool {
            for (int i = 0; i < propertieCount; i++) {
                objc_property_t property = properties[i];
                const char* typeName = getPropertyType(property);
                
                NSString *propertyTypeName = [[NSString alloc] initWithCString:typeName encoding:NSUTF8StringEncoding];
                [mPropertyTypesArray addObject:propertyTypeName];
            }
        }
        
        if (properties) {
            free(properties);
        }
        currentClass = [currentClass superclass];
    }
    return mPropertyTypesArray;
}

static const char *getPropertyType(objc_property_t property) {
    
    const char *attributes = property_getAttributes(property);
    
    char buffer[1 + strlen(attributes)];
    
    strcpy(buffer, attributes);
    
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        // 非对象类型
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // 利用NSData复制一份字符串
            return (const char *) [[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
            // 纯id类型
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
            // 对象类型
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            return (const char *) [[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

- (NSDictionary *)objectRecordPropertyDictionary {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    id currentClass = [self class];
    while (![NSStringFromClass(currentClass) isEqualToString:@"NSObject"]) {
        /// && ([NSBundle bundleForClass:currentClass] == [NSBundle mainBundle])
        unsigned int propertieCount = 0;
        objc_property_t* properties  = class_copyPropertyList(currentClass, &propertieCount);
        
        @autoreleasepool {
            for (int i = 0; i < propertieCount; i++) {
                objc_property_t property = properties[i];
                
                const char* name = property_getName(property);
                NSString* propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                NSObject* value = [self valueForKey:propertyName];
                Class objectClass = object_getClass(value);
                
                if  (objectClass != nil) {
                    NSString* className = NSStringFromClass(objectClass);
                    
                    if ([className rangeOfString:@"NS"].length != 0) {
                        if ([className rangeOfString:@"String"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Number"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Data"].length != 0) {
                            parameters[propertyName] = value;
                        } else if ([className rangeOfString:@"Array"].length != 0) {
                            NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                            parameters[propertyName] = arr;
                        } else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                            NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                            parameters[propertyName] = dic;
                        } else {
                            continue;
                        }
                    } else if ([className rangeOfString:@"Block"].length != 0) {
                        continue;
                    } else {
                        NSDictionary* dic = [(NSObject *)value objectRecordPropertyDictionary];
                        parameters[propertyName] = dic;
                    }
                }
            }
        }
        
        if (properties) {
            free(properties);
        }
        currentClass = [currentClass superclass];
    }
    return parameters;
}

@end

@implementation NSArray (KeyValue)

- (NSArray *)arrayRecordPropertyArray{
    
    NSInteger count = self.count;
    
    NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        
        NSObject* value = self[i];
        
        Class objectClass = object_getClass(value);
        
        if  (objectClass != nil) {
            NSString* className = NSStringFromClass(objectClass);
            
            if ([className rangeOfString:@"NS"].length != 0)  {
                if ([className rangeOfString:@"String"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Number"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Data"].length != 0) {
                    [parameters addObject:value];
                }
                else if ([className rangeOfString:@"Array"].length != 0) {
                    NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                    [parameters addObject: arr];
                }
                else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                    NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                    [parameters addObject: dic];
                }
                else {
                    continue;
                }
            }
            else if ([className rangeOfString:@"Block"].length != 0) {
                continue;
            }
            else {
                NSDictionary* dic = [(NSObject *)value objectRecordPropertyDictionary];
                [parameters addObject: dic];
            }
        }
    }
    return parameters;
}

@end


@implementation NSDictionary (KeyValue)

- (NSDictionary *)dictionaryRecordPropertyDictionary {
    NSInteger count = self.allKeys.count;
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        
        NSString* key = self.allKeys[i];
        NSObject* value = self[key];
        
        Class objectClass = object_getClass(value);
        
        if  (objectClass != nil) {
            NSString* className = NSStringFromClass(objectClass);
            
            if ([className rangeOfString:@"NS"].length != 0)  {
                if ([className rangeOfString:@"String"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Number"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Data"].length != 0) {
                    [parameters setObject:value forKey:key];
                }
                else if ([className rangeOfString:@"Array"].length != 0) {
                    NSArray* arr = [(NSArray *)value arrayRecordPropertyArray];
                    [parameters setObject:arr forKey:key];
                }
                else if ([className rangeOfString:@"Dictionary"].length != 0)  {
                    NSDictionary* dic = [(NSDictionary *)value dictionaryRecordPropertyDictionary];
                    [parameters setObject:dic forKey:key];
                }
                else {
                    continue;
                }
            }
            else if ([className rangeOfString:@"Block"].length != 0) {
                continue;
            }
            else {
                NSDictionary* dic = [(NSObject *)value objectRecordPropertyDictionary];
                [parameters setObject:dic forKey:key];
            }
        }
    }
    return parameters;
}

@end
