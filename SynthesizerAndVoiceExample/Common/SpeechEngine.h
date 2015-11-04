/*
	File:		SpeechEngine.h

	Contains:	Definition of the SPI between the Speech Synthesis API and a speech engine that
			implements the actual synthesis technology.  Each voice is matched to its appropriate
			speech engine via a type code stored in the voice.

			This documentation requires an understanding of the Speech Synthesis Manager
	Version:	1.0

	Copyright:	© 2000-2007 by Apple Inc., all rights reserved.

*/

/*
 * VOICES
 *
 * Voices are bundles installed in DOMAIN/Library/Speech/Voices/YOUR_VOICE_NAME.SpeechVoice, where DOMAIN is one of three
 * domains: system, local, or user.
 *
 * If the voice is designed to run on Mac OS X 10.4 and earlier it must contain a VoiceDescription file at the location YOUR_VOICE_NAME.SpeechVoice/Contents/Resources/VoiceDescription.
 * The VoiceDescription file contains the voice's attributes in binary form using the struct VoiceDescription, as defined in SpeechSynthesis.h.
 * The voice's Info.plist file should also include additional voice attributes that VoiceOver uses (VoiceSupportedCharacters & VoiceIndividuallySpokenCharacters).
 *
 * If the voice will only support Mac OS X 10.5 and later, then a VoiceDescription file is not necesary and all voice attributes should be defined in the voice's Info.plist file.
 * 
 * NOTE: Voice bundle names cannot contain spaces.  However, the name of the voice that is specified in the
 * VoiceDescription file and displayed to the user can contain spaces.
 *
 *
 */

#define kSpeechVoiceSynthesizerNumericID		CFSTR("VoiceSynthesizerNumericID")
#define kSpeechVoiceNumericID					CFSTR("VoiceNumericID")


/*
 * SYNTHESIZERS
 *
 * Speech Synthesizers are bundles installed in /System/Library/Speech/Synthesizers/YOUR_SYNTHESIZER_NAME.SpeechSynthesizer
 *
 * Define _SUPPORT_SPEECH_SYNTHESIS_IN_MAC_OS_X_VERSION_10_0_THROUGH_10_4__ as true if your synthesizer is intended to run on Mac OS X 10.4 and earlier.
 *
 *
 *
 */


#define kSpeechEngineTypeArrayKey CFSTR("SpeechEngineTypeArray")

#if _SUPPORT_SPEECH_SYNTHESIS_IN_MAC_OS_X_VERSION_10_0_THROUGH_10_4__
/* Engine Description (in YOUR_SYNTHESIZER_NAME.SpeechSynthesizer/Contents/Resources/SpeechEngineDescription) */
typedef struct SpeechEngineDesc
{
	long		fFileFormat;	// Currently 2
	OSType		fEngineType[3]; // Voice types handled, padded with \0\0\0\0 if necessary
};

/* Engine (in YOUR_SYNTHESIZER_NAME.SpeechSynthesizer/Contents/MacOS/YOUR_SYNTHESIZER_NAME) */
#endif

/* Token to identify your private per-channel data */
typedef long SpeechChannelIdentifier;


/* API: These functions must be defined and exported with these names and extern "C" linkage. All of them
   return an OSStatus result.
*/


#ifdef __cplusplus
extern "C" {
#endif

/* Open channel - called from NewSpeechChannel, passes back in *ssr a unique SpeechChannelIdentifier value of your choosing. */
long	SEOpenSpeechChannel	( SpeechChannelIdentifier* ssr );

/* Set the voice to be used for the channel. Voice type guaranteed to be compatible with above spec */
long 	SEUseVoice 			( SpeechChannelIdentifier ssr, VoiceSpec* voice, CFBundleRef inVoiceSpecBundle );

/* Close channel */
long	SECloseSpeechChannel( SpeechChannelIdentifier ssr ); 

/* Analogous to corresponding speech synthesis API calls, except for details noted below */

/* Must also be able to parse and handle the embedded commands defined in Inside Macintosh: Speech */
long 	SESpeakCFString			( SpeechChannelIdentifier ssr, CFStringRef text, CFDictionaryRef options);
long 	SECopySpeechProperty	( SpeechChannelIdentifier ssr, CFStringRef property, CFTypeRef * object );
long 	SESetSpeechProperty		( SpeechChannelIdentifier ssr, CFStringRef property, CFTypeRef object);
long 	SEUseSpeechDictionary 	( SpeechChannelIdentifier ssr, CFDictionaryRef speechDictionary );
long 	SECopyPhonemesFromText 	( SpeechChannelIdentifier ssr, CFStringRef text, CFStringRef * phonemes);

#if _SUPPORT_SPEECH_SYNTHESIS_IN_MAC_OS_X_VERSION_10_0_THROUGH_10_4__

/* Must also be able to parse and handle the embedded commands defined in Inside Macintosh: Speech */
long 	SESpeakBuffer		( SpeechChannelIdentifier ssr, Ptr textBuf, long byteLen, long controlFlags ); 
long 	SEStopSpeechAt 		( SpeechChannelIdentifier ssr, unsigned long whereToPause); 
long 	SEPauseSpeechAt		( SpeechChannelIdentifier ssr, unsigned long whereToPause );
long 	SEContinueSpeech	( SpeechChannelIdentifier ssr );
long 	SETextToPhonemes 	( SpeechChannelIdentifier ssr, char* textBuf, long textBytes, void** phonemeBuf, long* phonBytes);
long 	SEUseDictionary 	( SpeechChannelIdentifier ssr, void* dictionary, long dictLength );

/* The soPhonemeSymbols call is passed as soPhonemeSymbolsPtr ('phsp'); speechInfo passes a pointer to a (void *)
   The engine has to allocate a sufficiently sized area with malloc(), fill it in, and store it into 
   *(void **)speechInfo. The API will dispose the memory. The call is rarely used and can probably be left 
   unimplemented. 

   Must be able to handle all selectors defined in Inside Macintosh: Speech.
*/
long 	SEGetSpeechInfo		( SpeechChannelIdentifier ssr, unsigned long selector, void* speechInfo );

/* soCurrentVoice will be handled by the API (and SEUseVoice, if necessary 

   Must be able to handle all selectors defined in Inside Macintosh: Speech, including those for the various callbacks,
   with the exception of soCurrentA5 and soSoundOutput.
*/
long 	SESetSpeechInfo		( SpeechChannelIdentifier ssr, unsigned long selector, void* speechInfo );

/* Same as SEGetSpeechInfo(ssr, soStatus, status). Will probably get dropped in next release of MacOS X */
long 	SESpeechStatus 		( SpeechChannelIdentifier ssr, SpeechStatusInfo * status );

#endif

#ifdef __cplusplus
}
#endif

