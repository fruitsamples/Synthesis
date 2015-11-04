/*
	SynthesizerSimulator.m
	SynthesizerAndVoiceExample

	Copyright © 2007 Apple Inc.  All Rights Reserved.

	Descrition: The SynthesizerSimulator object simulates the basic operation of a 
	Mac OS X speech synthesizer by playing an audio file instead of actually 
	synthesizing a given text.

	Disclaimer:  IMPORTANT:  This Apple software is supplied to you by Apple Inc.
	("Apple") in consideration of your agreement to the following terms, and your
	use, installation, modification or redistribution of this Apple software
	constitutes acceptance of these terms.  If you do not agree with these terms,
	please do not use, install, modify or redistribute this Apple software.

	In consideration of your agreement to abide by the following terms, and subject
	to these terms, Apple grants you a personal, non-exclusive license, under Apple's
	copyrights in this original Apple software (the "Apple Software"), to use,
	reproduce, modify and redistribute the Apple Software, with or without
	modifications, in source and/or binary forms; provided that if you redistribute
	the Apple Software in its entirety and without modifications, you must retain
	this notice and the following text and disclaimers in all such redistributions of
	the Apple Software.  Neither the name, trademarks, service marks or logos of
	Apple Inc. may be used to endorse or promote products derived from the
	Apple Software without specific prior written permission from Apple.  Except as
	expressly stated in this notice, no other rights or licenses, express or implied,
	are granted by Apple herein, including but not limited to any patent rights that
	may be infringed by your derivative works or by other works in which the Apple
	Software may be incorporated.

	The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
	WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
	WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
	PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
	COMBINATION WITH YOUR PRODUCTS.

	IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
	GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
	OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
	(INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
*/

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "SynthesizerSimulator.h"

NSMutableArray * sChannels = NULL;

static Boolean ConvertCFStringToOSType(CFStringRef string, OSType * type);
static CFStringRef CopyCFStringFromOSType(OSType type);

@interface SynthesizerSimulator : NSObject {

	NSSound *				_sound;
	NSString *				_spokenString;
	VoiceSpec				_voiceSpec;
	NSMutableDictionary *	_properties;
	NSTimer *				_wordCallbackTimer;
	NSTimer *				_phonemeCallbackTimer;
	long					_phonemeCallbackCharIndex;
	long					_wordCallbackCharIndex;

}

- (id)init;
- (void)setVoice:(VoiceSpec *)voiceSpec;
- (void)getVoice:(VoiceSpec *)voiceSpec;
- (void)startSpeaking:(NSString *)string;
- (void)stopSpeaking;
- (void)pauseSpeaking;
- (void)continueSpeaking;
- (void)setObject:(id)object forProperty:(NSString *)property;
- (id)copyProperty:(NSString *)property;
- (void)performSimulatedCallbacks;

@end


@implementation SynthesizerSimulator

- (id)init
{
	if ((self = [super init])) {
		
		_sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[SynthesizerSimulator class]] pathForResource:[NSString stringWithFormat:@"Sound0"] ofType:@"aiff"] byReference:false];
		[_sound setDelegate:self];
		_properties = [NSMutableDictionary new];			
		
		[_properties setObject:(NSString *)kSpeechModeText forKey:(NSString *)kSpeechInputModeProperty];
		[_properties setObject:(NSString *)kSpeechModeNormal forKey:(NSString *)kSpeechCharacterModeProperty];
		[_properties setObject:(NSString *)kSpeechModeNormal forKey:(NSString *)kSpeechNumberModeProperty];
		[_properties setObject:[NSNumber numberWithFloat:180.0] forKey:(NSString *)kSpeechRateProperty];
		[_properties setObject:[NSNumber numberWithFloat:100.0] forKey:(NSString *)kSpeechPitchBaseProperty];
		[_properties setObject:[NSNumber numberWithFloat:30.0] forKey:(NSString *)kSpeechPitchModProperty];
		[_properties setObject:[NSNumber numberWithFloat:1.0] forKey:(NSString *)kSpeechVolumeProperty];
		[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:0], kSpeechStatusOutputBusy, [NSNumber numberWithLong:0], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];

	}
	return self;
}

- (void)dealloc;
{
	[_phonemeCallbackTimer invalidate];
	[_phonemeCallbackTimer release];
	[_spokenString release];
	[_sound release];
	[_properties release];
	
	[super dealloc];
}

- (void)setVoice:(VoiceSpec *)voiceSpec
{
	_voiceSpec = *voiceSpec;
}

- (void)getVoice:(VoiceSpec *)voiceSpec
{
	*voiceSpec = _voiceSpec;
}

- (void)startSpeaking:(NSString *)string;
{
	if (! [_properties objectForKey:(NSString *)kSpeechOutputToFileURLProperty]) {

		// We're simulating word and phoneme callbacks by having a timer perform the callback every 1/4 second.
		_spokenString = [string retain];
		_phonemeCallbackCharIndex = 0;
		_phonemeCallbackTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(performSimulatedCallbacks) userInfo:NULL repeats:YES] retain];

		// Do our simluated speaking by playing an audio file, which is static and has no relationship to the given text.
		[_sound setCurrentTime:0.0];
		[_sound play];
		[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:1], kSpeechStatusOutputBusy, [NSNumber numberWithLong:0], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];
	}
}

- (void)stopSpeaking
{
	// We're done with the simulated callbacks, release our timer.
	[_phonemeCallbackTimer invalidate];
	[_phonemeCallbackTimer release];
	_phonemeCallbackTimer = NULL;
	[_spokenString release];
	_spokenString = NULL;
	
	[_sound stop];
	[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:0], kSpeechStatusOutputBusy, [NSNumber numberWithLong:0], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];
}

- (void)pauseSpeaking
{
	[_sound pause];
	[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:0], kSpeechStatusOutputBusy, [NSNumber numberWithLong:1], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];
}

- (void)continueSpeaking
{
	[_sound resume];
	[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:1], kSpeechStatusOutputBusy, [NSNumber numberWithLong:0], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];
}

- (void)setObject:(id)object forProperty:(NSString *)property
{
	if (object) {
		[_properties setObject:object forKey:property];
	}
	else {
		[_properties removeObjectForKey:property];
	}
}

- (id)copyProperty:(NSString *)property
{
	return [[_properties objectForKey:property] retain];
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool
{
	// We're done with the simulated callbacks
	[_phonemeCallbackTimer invalidate];
	[_phonemeCallbackTimer release];
	_phonemeCallbackTimer = NULL;
	[_spokenString release];
	_spokenString = NULL;

	[_properties setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:0], kSpeechStatusOutputBusy, [NSNumber numberWithLong:0], kSpeechStatusOutputPaused, [NSNumber numberWithLong:0], kSpeechStatusNumberOfCharactersLeft, [NSNumber numberWithLong:0], kSpeechStatusPhonemeCode, NULL] forKey:(NSString *)kSpeechStatusProperty];

	SpeechDoneProcPtr callBackProcPtr = (SpeechDoneProcPtr)[[_properties objectForKey:(NSString *)kSpeechSpeechDoneCallBack] longValue];
	if (callBackProcPtr) {
		(*callBackProcPtr)((SpeechChannel)self, [[_properties objectForKey:(NSString *)kSpeechRefConProperty] longValue]);
	}
}

- (void)performSimulatedCallbacks
{

	if (_spokenString && _phonemeCallbackCharIndex < [_spokenString length]) {
	
		// Skip whitespace, and determine if this is the beginning of the next word
		BOOL foundWordBoundary = (_phonemeCallbackCharIndex == 0);
		while (_phonemeCallbackCharIndex < [_spokenString length] && ! [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[_spokenString characterAtIndex:_phonemeCallbackCharIndex]]) {
			_phonemeCallbackCharIndex++;

			// Make CF-based error callback whenever it sees the beginning of an embedded command.
			// Note: this not the recommended approach for handling embedded commands, but only an example of how to call the error callback function.
			SpeechErrorCFProcPtr errorCallBackProcPtr = (SpeechErrorCFProcPtr)[[_properties objectForKey:(NSString *)kSpeechErrorCFCallBack] longValue];
			if (errorCallBackProcPtr && _phonemeCallbackCharIndex < [_spokenString length] - 1 && [_spokenString characterAtIndex:_phonemeCallbackCharIndex] == '[' && [_spokenString characterAtIndex:_phonemeCallbackCharIndex+1] == '[') {
					
				CFMutableDictionaryRef mutableUserInfo = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
				if (mutableUserInfo) {
					CFDictionarySetValue(mutableUserInfo, (const void *)kCFErrorDescriptionKey, (const void *)CFSTR("Beginning of embedded command.  This is just a demonstration of a CF-based error callback and not an actual error."));
					CFDictionarySetValue(mutableUserInfo, (const void *)kSpeechErrorCallbackSpokenString, (const void *)_spokenString);
					
					CFNumberRef offsetAsCFNumber = CFNumberCreate(NULL, kCFNumberLongType, (const void *)&_phonemeCallbackCharIndex);
					if (offsetAsCFNumber) {
						CFDictionarySetValue(mutableUserInfo, (const void *)kSpeechErrorCallbackCharacterOffset, (const void *)offsetAsCFNumber);
						CFRelease(offsetAsCFNumber);
					}

					CFErrorRef theError =  CFErrorCreate(NULL, kCFErrorDomainOSStatus, noErr, mutableUserInfo);
					if (theError) {
						(*errorCallBackProcPtr)((SpeechChannel)self, [[_properties objectForKey:(NSString *)kSpeechRefConProperty] longValue], theError);
						CFRelease(theError);
					}
					CFRelease(mutableUserInfo);
				}
			}			

			foundWordBoundary = true;
		}
		

		if (_phonemeCallbackCharIndex < [_spokenString length]) {
			
			// Make simulated phoneme callback
			// Note: we just send a random phoneme opcode.
			SpeechPhonemeProcPtr phonemeCallBackProcPtr = (SpeechPhonemeProcPtr)[[_properties objectForKey:(NSString *)kSpeechPhonemeCallBack] longValue];
			if (phonemeCallBackProcPtr) {
				(*phonemeCallBackProcPtr)((SpeechChannel)self, [[_properties objectForKey:(NSString *)kSpeechRefConProperty] longValue], (SInt16)((random() % 47) + 2));
			}
			
			if (foundWordBoundary) {
			
				// Make simulated word callback before the beginnin of words
				SpeechWordCFProcPtr wordCallBackProcPtr = (SpeechWordCFProcPtr)[[_properties objectForKey:(NSString *)kSpeechWordCFCallBack] longValue];
				if (wordCallBackProcPtr) {
					
					// Find end of word in order to determine length of word.
					// Note: a normal synthesizer would have already parsed the text in a much more sophisticated way, so this is not an example of who a synthesizer should determine word boundaries.
					CFIndex charIndex = _phonemeCallbackCharIndex;
					while (charIndex < [_spokenString length] && ! [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[_spokenString characterAtIndex:charIndex]]) {
						charIndex++;
					}
					CFIndex wordLength = 0;
					if (charIndex >= [_spokenString length] && _phonemeCallbackCharIndex < [_spokenString length]) {
						wordLength = [_spokenString length] - _phonemeCallbackCharIndex; 
					}
					else if (charIndex > _phonemeCallbackCharIndex) {
						wordLength = charIndex - _phonemeCallbackCharIndex; 
					}
					
					CFRange wordRange = CFRangeMake(_phonemeCallbackCharIndex, wordLength);
					(*wordCallBackProcPtr)((SpeechChannel)self, [[_properties objectForKey:(NSString *)kSpeechRefConProperty] longValue], (CFStringRef)_spokenString, wordRange);
				}
			}
		}
		_phonemeCallbackCharIndex++;
	}
}

@end


SpeechChannelIdentifier SynthSimCreateChannel()
{

	if (sChannels == NULL) {
		sChannels = [NSMutableArray new];
	}

	SynthesizerSimulator * simulator = [SynthesizerSimulator new];
	[sChannels addObject:simulator];
	[simulator release];
	
	return (SpeechChannelIdentifier)simulator;
}

long SynthSimDisposeChannel(SpeechChannelIdentifier chan)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[sChannels removeObject:(id)chan];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimUseVoice(SpeechChannelIdentifier chan, VoiceSpec * voiceSpec)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[(SynthesizerSimulator *)chan setVoice:voiceSpec];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimStartSpeaking(SpeechChannelIdentifier chan, CFStringRef string)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[(SynthesizerSimulator *)chan startSpeaking:(NSString *)string];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimStopSpeaking(SpeechChannelIdentifier chan)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[(SynthesizerSimulator *)chan stopSpeaking];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimPauseSpeaking(SpeechChannelIdentifier chan)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[(SynthesizerSimulator *)chan pauseSpeaking];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimContinueSpeaking(SpeechChannelIdentifier chan)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		[(SynthesizerSimulator *)chan continueSpeaking];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimSetProperty(SpeechChannelIdentifier chan, CFStringRef property, CFTypeRef object)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
	
	
		[(SynthesizerSimulator *)chan setObject:(id)object forProperty:(NSString *)property];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

 long SynthSimCopyProperty(SpeechChannelIdentifier chan, CFStringRef property, CFTypeRef * object)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		if (object) {
			*object = [(SynthesizerSimulator *)chan copyProperty:(NSString *)property];
		}
		else {
			error = paramErr;
		}
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimSetSpeechInfo(SpeechChannelIdentifier chan, unsigned long selector, void * speechInfo)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
	
		NSString * property = (NSString *)CopyCFStringFromOSType(selector);
		switch(selector) {
		
			case soInputMode:
			case soCharacterMode:
			case soNumberMode:
				{
					NSString * stringValue = (NSString *)CopyCFStringFromOSType(*(long *)speechInfo);
					[(SynthesizerSimulator *)chan setObject:stringValue forProperty:property];
					[stringValue release];
				}
				break;
			
			case soRefCon:
			case soTextDoneCallBack:
			case soSpeechDoneCallBack:
			case soSyncCallBack:
			case soErrorCallBack:
			case soPhonemeCallBack:
			case soWordCallBack:
			case soOutputToFileWithCFURL:
				[(SynthesizerSimulator *)chan setObject:[NSNumber numberWithLong:(long)speechInfo] forProperty:property];
				break;
				
			case soRate:
			case soPitchBase:
			case soPitchMod:
			case soVolume:
				[(SynthesizerSimulator *)chan setObject:[NSNumber numberWithFloat:(float)(*(Fixed *)speechInfo / 65536.0)] forProperty:property];
				break;
				
			case soReset:
				break;

			default:
				error = siUnknownInfoType;
				break;
		}

		[property release];
	}
	else {
		error = noSynthFound;
	}
	return error;
}

long SynthSimGetSpeechInfo(SpeechChannelIdentifier chan, unsigned long selector, void* speechInfo)
{
	long error = noErr;
	if ([sChannels containsObject:(id)chan]) {
		if (speechInfo) {
			NSString * property = (NSString *)CopyCFStringFromOSType(selector);
			id object = [(SynthesizerSimulator *)chan copyProperty:property];
			
			if (object) {
			
			   switch(selector) {
				
					case soInputMode:
					case soCharacterMode:
					case soNumberMode:
						ConvertCFStringToOSType((CFStringRef)object, (OSType *)speechInfo);
						break;
						
					case soRecentSync:
						*(SInt32 *)speechInfo = [object longValue];
						break;
				
					case soRate:
					case soPitchBase:
					case soPitchMod:
					case soVolume:
						*(Fixed *)speechInfo = [object floatValue] * 65536.0;
						break;
						
					case soCurrentVoice:
						[(SynthesizerSimulator *)chan getVoice:(VoiceSpec *)speechInfo];
						break;

					case soStatus:
						((SpeechStatusInfo *)speechInfo)->outputBusy = [[object objectForKey:(NSString *)kSpeechStatusOutputBusy] longValue];
						((SpeechStatusInfo *)speechInfo)->outputPaused = [[object objectForKey:(NSString *)kSpeechStatusOutputPaused] longValue];
						((SpeechStatusInfo *)speechInfo)->inputBytesLeft = [[object objectForKey:(NSString *)kSpeechStatusNumberOfCharactersLeft] longValue];
						((SpeechStatusInfo *)speechInfo)->phonemeCode = [[object objectForKey:(NSString *)kSpeechStatusPhonemeCode] longValue];
						break;
						
					default:
						error = siUnknownInfoType;
						break;
				}
			}
			else {
				error = siUnknownInfoType;
			}
			
			[property release];
			[object release];
		}
		else {
			error = paramErr;
		}
	}
	else {
		error = noSynthFound;
	}
	return error;
}


static Boolean ConvertCFStringToOSType(CFStringRef string, OSType * type)
{
	Boolean wasSuccessful = false;
	if (CFStringGetLength(string) == 4) {
		CFIndex usedBufLen = 0;
		if (CFStringGetBytes(string, CFRangeMake(0, 4), kCFStringEncodingMacRoman, 0x20, false, (UInt8 *)type, 4, &usedBufLen) == 4) {
			*type = CFSwapInt32BigToHost(*type);
			wasSuccessful = true;
		}
	}

	return wasSuccessful;
}

static CFStringRef CopyCFStringFromOSType(OSType type)
{
	OSType theType = CFSwapInt32HostToBig(type);
	return CFStringCreateWithBytes(NULL, (const UInt8 *)&theType, 4, kCFStringEncodingMacRoman, false);
}
