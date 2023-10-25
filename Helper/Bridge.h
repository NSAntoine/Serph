//
//  Bridge.h
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

#ifndef Bridge_h
#define Bridge_h

#import <IOKit/IOKitLib.h>

CF_IMPLICIT_BRIDGING_ENABLED

IOReturn IOPMSetPMPreference(CFStringRef, CFTypeRef, CFTypeRef);
IOReturn IOPMCopyPMSetting(CFStringRef, CFTypeRef, CFTypeRef *);
CFDictionaryRef IOPMCopyActivePMPreferences();

CF_IMPLICIT_BRIDGING_DISABLED

#endif /* Bridge_h */
