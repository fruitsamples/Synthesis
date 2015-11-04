/*
 IMPORTANT: This Apple software is supplied to you by Apple Computer,
 Inc. ("Apple") in consideration of your agreement to the following terms,
 and your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms.  If you do not agree with
 these terms, please do not use, install, modify or redistribute this Apple
 software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following text
 and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
 ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT
 LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY
 OF SUCH DAMAGE.


	ExampleWindow.m
	NSSpeechSynthesizerExample
	
	Copyright (c) 2003-2005 Apple Computer. All rights reserved.
*/

#import "OptionsSheet.h"

const NSUInteger kNumOfFixedMenuItemsInVoicePopup = 2;

@interface NSSpeechOptionsSheet (NSSpeechOptionsSheetPrivate)
- (void)_updateVoicesPopup;
@end

@implementation NSSpeechOptionsSheet

- (void)updateWithSettings:(NSMutableDictionary *)settings
{
	// Set up voices popup
	[self _updateVoicesPopup];
	[_voicePopupButton selectItemAtIndex:0];
	
	// Retain the passed in settings
	[_currentSettings release];
    _currentSettings = [settings retain];

	id valueObject = [_currentSettings objectForKey:NSSpeechRateProperty];
	if (valueObject) {
		[_rateSlider setFloatValue:[valueObject floatValue]];
	}
	else {
		[_rateSlider setEnabled:false];
	}
	
	valueObject = [_currentSettings objectForKey:NSSpeechVolumeProperty];
	if (valueObject) {
		[_volumeSlider setFloatValue:[valueObject floatValue]];
	}
	else {
		[_volumeSlider setEnabled:false];
	}
	
	valueObject = [_currentSettings objectForKey:NSSpeechPitchBaseProperty];
	if (valueObject) {
		[_pitchBaseSlider setFloatValue:[valueObject floatValue]];
	}
	else {
		[_pitchBaseSlider setEnabled:false];
	}
	
	valueObject = [_currentSettings objectForKey:NSSpeechPitchModProperty];
	if (valueObject) {
		[_pitchModSlider setFloatValue:[valueObject floatValue]];
	}
	else {
		[_pitchModSlider setEnabled:false];
	}

	valueObject = [_currentSettings objectForKey:NSSpeechInputModeProperty];
	if (valueObject) {
		[_phonemeModeCheckboxButton setIntValue:([valueObject isEqualToString:NSSpeechModePhoneme])?true:false];
	}
	else {
		[_phonemeModeCheckboxButton setEnabled:false];
	}
	
	valueObject = [_currentSettings objectForKey:NSSpeechCharacterModeProperty];
	if (valueObject) {
		[_charByCharCheckboxButton setIntValue:([valueObject isEqualToString:NSSpeechModeLiteral])?true:false];
	}
	else {
		[_charByCharCheckboxButton setEnabled:false];
	}
	
	valueObject = [_currentSettings objectForKey:NSSpeechNumberModeProperty];
	if (valueObject) {
		[_digitByDigitCheckboxButton setIntValue:([valueObject isEqualToString:NSSpeechModeLiteral])?true:false];
	}
	else {
		[_digitByDigitCheckboxButton setEnabled:false];
	}

	[_voicePopupButton selectItemAtIndex:0];
	valueObject = [_currentSettings objectForKey:@"NSSpeechVoice"];
	if (valueObject) {
		NSUInteger	foundIndex = [_voiceIdentifierList indexOfObjectIdenticalTo:valueObject];
		if (foundIndex != NSNotFound) {
			[_voicePopupButton selectItemAtIndex:foundIndex + kNumOfFixedMenuItemsInVoicePopup];
		}
	}

	valueObject = [_currentSettings objectForKey:@"NSSpeechBoundary"];
	if (valueObject) {
		[_immediatelyRadioButton setIntValue:([valueObject intValue] == NSSpeechImmediateBoundary)?true:false];
		[_afterWordRadioButton setIntValue:([valueObject intValue] == NSSpeechWordBoundary)?true:false];
		[_afterSentenceRadioButton setIntValue:([valueObject intValue] == NSSpeechSentenceBoundary)?true:false];
	}
	else {
		[_immediatelyRadioButton setEnabled:false];
		[_afterWordRadioButton setEnabled:false];
		[_afterSentenceRadioButton setEnabled:false];
	}
}

- (IBAction)saveSettingsButtonSelected:(id)sender
{

	if ([_rateSlider isEnabled]) {
		[_currentSettings setObject:[NSNumber numberWithFloat:[_rateSlider floatValue]] forKey:NSSpeechRateProperty];
	}
	
	if ([_volumeSlider isEnabled]) {
		[_currentSettings setObject:[NSNumber numberWithFloat:[_volumeSlider floatValue]] forKey:NSSpeechVolumeProperty];
	}
	
	if ([_pitchBaseSlider isEnabled]) {
		[_currentSettings setObject:[NSNumber numberWithFloat:[_pitchBaseSlider floatValue]] forKey:NSSpeechPitchBaseProperty];
	}
	
	if ([_pitchModSlider isEnabled]) {
		[_currentSettings setObject:[NSNumber numberWithFloat:[_pitchModSlider floatValue]] forKey:NSSpeechPitchModProperty];
	}
	
	if ([_phonemeModeCheckboxButton isEnabled]) {
		[_currentSettings setObject:([_phonemeModeCheckboxButton intValue])?NSSpeechModePhoneme:NSSpeechModeText forKey:NSSpeechInputModeProperty];
	}
	
	if ([_digitByDigitCheckboxButton isEnabled]) {
		[_currentSettings setObject:([_digitByDigitCheckboxButton intValue])?NSSpeechModeLiteral:NSSpeechModeNormal forKey:NSSpeechNumberModeProperty];
	}
	
	if ([_charByCharCheckboxButton isEnabled]) {
		[_currentSettings setObject:([_charByCharCheckboxButton intValue])?NSSpeechModeLiteral:NSSpeechModeNormal forKey:NSSpeechCharacterModeProperty];
	}

	if ([_voicePopupButton isEnabled]) {
		if ([_voicePopupButton indexOfSelectedItem] >= kNumOfFixedMenuItemsInVoicePopup) {
			id voiceIdentifier = [_voiceIdentifierList objectAtIndex:[_voicePopupButton indexOfSelectedItem] - kNumOfFixedMenuItemsInVoicePopup];
			if (voiceIdentifier) {
				[_currentSettings setObject:voiceIdentifier forKey:@"NSSpeechVoice"];
			}
		}
		else {
			[_currentSettings setObject:[NSSpeechSynthesizer defaultVoice] forKey:@"NSSpeechVoice"];
		}
	}

	if ([_immediatelyRadioButton isEnabled] && [_afterWordRadioButton isEnabled] && [_afterSentenceRadioButton isEnabled]) {
		
		if ([_immediatelyRadioButton intValue]) {
			[_currentSettings setObject:[NSNumber numberWithLong:NSSpeechImmediateBoundary] forKey:@"NSSpeechBoundary"];
		}
		else if ([_afterWordRadioButton intValue]) {
			[_currentSettings setObject:[NSNumber numberWithLong:NSSpeechWordBoundary] forKey:@"NSSpeechBoundary"];
		}
		else if ([_afterSentenceRadioButton intValue]) {
			[_currentSettings setObject:[NSNumber numberWithLong:NSSpeechSentenceBoundary] forKey:@"NSSpeechBoundary"];
		}
	}

	[NSApp endSheet:[self window] returnCode:kOptionsSaveReturnCode];
}

- (IBAction)cancelButtonSelected:(id)sender
{
	[NSApp endSheet:[self window] returnCode:kOptionsCancelReturnCode];
}

- (IBAction)useDefaultsButtonSelected:(id)sender
{
	[NSApp endSheet:[self window] returnCode:kOptionsResetReturnCode];
}

- (void)_updateVoicesPopup 
{
	[_voiceIdentifierList release];
	_voiceIdentifierList = [NSMutableArray new];

    // Delete any items in the voice menu
    while([_voicePopupButton numberOfItems] > kNumOfFixedMenuItemsInVoicePopup) {
        [_voicePopupButton removeItemAtIndex:[_voicePopupButton numberOfItems] - 1];
	}
    
	NSString * aVoice = NULL;
	NSEnumerator * voiceEnumerator = [[NSSpeechSynthesizer availableVoices] objectEnumerator];
	while(aVoice = [voiceEnumerator nextObject]) {
		[_voiceIdentifierList addObject:aVoice];
		[_voicePopupButton addItemWithTitle:[[NSSpeechSynthesizer attributesForVoice:aVoice] objectForKey:NSVoiceName]];
	}
}


@end


