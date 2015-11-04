/*
	MySynthesizer.c
	SynthesizerAndVoiceExample

	Copyright (c) 2002-2007 Apple Inc. All rights reserved.

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

#import <ApplicationServices/ApplicationServices.h>
#import "SynthesizerSimulator.h"

// This example uses the synthesizer plug-in API supported in Mac OS X 10.4 and earlier versions.

// Defining this causes SpeechEngine.h to define the older synthesizer plug-in API.
#define _SUPPORT_SPEECH_SYNTHESIS_IN_MAC_OS_X_VERSION_10_0_THROUGH_10_4__ true
#import "SpeechEngine.h"

/* Open channel - called from NewSpeechChannel, passes back in *ssr a unique SpeechChannelIdentifier value of your choosing. */
long	SEOpenSpeechChannel( SpeechChannelIdentifier* ssr )
{

    // Pass back an identifier for this new channel.
	SpeechChannelIdentifier newChannel = SynthSimCreateChannel();
    if (ssr) {
        *ssr = newChannel;
	}
        
    // Show info about this call
    printf( "SEOpenSpeechChannel - speech channel identifier: %d\n", (ssr)?(int)*ssr:0 );
    
    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	synthOpenFailed		-241	Could not open another speech synthesizer channel 

    return (newChannel)?noErr:synthOpenFailed;
}

/* Set the voice to be used for the channel. Voice type guaranteed to be compatible with above spec */
long 	SEUseVoice( SpeechChannelIdentifier ssr, VoiceSpec* voice, CFBundleRef inVoiceSpecBundle )
{

	long error = SynthSimUseVoice(ssr, voice);

    // Show info about this call
    printf( "SEUseVoice - speech channel identifier: %d, voice creator: %d, voice identifier: %d, voice bundle info: \n", (int)ssr, (voice)?(int)voice->creator:0, (voice)?(int)voice->id:0 );
    if (inVoiceSpecBundle) {
        CFShow(inVoiceSpecBundle);
	}
	
    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 
    //	voiceNotFound		-244	Voice resource not found 

    return error;
}

/* Close channel */
long	SECloseSpeechChannel( SpeechChannelIdentifier ssr )
{

	long error = SynthSimDisposeChannel(ssr);

    // Show info about this call
    printf( "SECloseSpeechChannel - speech channel identifier: %d\n", (int)ssr );

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 

/* Same as SEGetSpeechInfo(ssr, soStatus, status). Future versions of MacOS X may use SEGetSpeechInfo instead. */
long 	SESpeechStatus( SpeechChannelIdentifier ssr, SpeechStatusInfo * status )
{

	long error = SynthSimGetSpeechInfo(ssr, soStatus, status);

    // Show info about this call
    printf( "SESpeechStatus - speech channel identifier: %d\n", (int)ssr );
    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 


/* Analogous to corresponding speech synthesis API calls, except for details noted below */

/* Must also be able to parse and handle the embedded commands defined in Inside Macintosh: Speech */
long 	SESpeakBuffer( SpeechChannelIdentifier ssr, Ptr textBuf, long byteLen, long controlFlags )
{

	long error = SynthSimStartSpeaking(ssr, NULL);
	
    // Show info about this call
    printf( "SESpeakBuffer - speech channel identifier: %d, text: %s, length: %d, control flags: %d\n", (int)ssr, (char *)textBuf, (int)byteLen, (int)controlFlags );

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 
    //	synthNotReady		-242	Speech synthesizer is still busy speaking 

    return error;
} 

 
long 	SEStopSpeechAt( SpeechChannelIdentifier ssr, unsigned long whereToStop)
{

	long error = SynthSimStopSpeaking(ssr);

    // Show info about this call
    printf( "SEStopSpeechAt - speech channel identifier: %d, whereToStop: %d\n", (int)ssr, (int)whereToStop );

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 

 
long 	SEPauseSpeechAt( SpeechChannelIdentifier ssr, unsigned long whereToPause )
{

	long error = SynthSimPauseSpeaking(ssr);

    // Show info about this call
    printf( "SEPauseSpeechAt - speech channel identifier: %d, whereToPause: %d\n", (int)ssr, (int)whereToPause );

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 


long 	SEContinueSpeech( SpeechChannelIdentifier ssr )
{

	long error = SynthSimContinueSpeaking(ssr);

    // Show info about this call
    printf( "SEContinueSpeech - speech channel identifier: %d\n", (int)ssr);

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 


long 	SETextToPhonemes( SpeechChannelIdentifier ssr, char* textBuf, long textBytes, void** phonemeBuf, long* phonBytes)
{

    // Show info about this call
    printf( "SETextToPhonemes - speech channel identifier: %d\n", (int)ssr);

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return noErr;
} 


long 	SEUseDictionary( SpeechChannelIdentifier ssr, void* dictionary, long dictLength )
{

    // Show info about this call
    printf( "SETextToPhonemes - speech channel identifier: %d\n", (int)ssr);

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 
    //	bufTooSmall			-243	Output buffer is too small to hold result 
    //	badDictFormat		-246	Pronunciation dictionary format error 

    return noErr;
} 


/* 
    Pass back the information for the designated speech channel and selector
*/
long 	SEGetSpeechInfo( SpeechChannelIdentifier ssr, unsigned long selector, void* speechInfo )
{

	long error = SynthSimGetSpeechInfo(ssr, selector, speechInfo);

    // This routine is required to support the following selectors:
    //	soStatus                      = 'stat'
    //	soErrors                      = 'erro'
    //	soInputMode                   = 'inpt'
    //	soCharacterMode               = 'char'
    //	soNumberMode                  = 'nmbr'
    //	soRate                        = 'rate'
    //	soPitchBase                   = 'pbas'
    //	soPitchMod                    = 'pmod'
    //	soVolume                      = 'volm'
    //	soSynthType                   = 'vers'
    //	soRecentSync                  = 'sync'
    //	soPhonemeSymbols              = 'phsy'
	//
	// Optionally, you may support the following selector:
    //	soSynthExtension              = 'xtnd'
    //
    // NOTE: 	The selector soCurrentVoice is automatically handled by the API,
    // 			and selectors soCurrentA5, soSoundOutput are no longer necessary under Mac OS X.
    //
    //			The soPhonemeSymbols selector is passed as soPhonemeSymbolsPtr ('phsp'); speechInfo passes a pointer to a (void *)
    //			The engine has to allocate a sufficiently sized area with malloc(), fill it in, and store it into 
    //			*(void **)speechInfo. The API will dispose the memory. The call is rarely used and can probably be left unimplemented. 

    // Show info about this call
	OSType selectorAsTypeChars = CFSwapInt32HostToBig(selector);
    printf( "SEGetSpeechInfo - speech channel identifier: %d, selector: %.4s, result: %d\n", (int)ssr, (char*)&selectorAsTypeChars, (int)error);

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	siUnknownInfoType	-231	Feature not implemented on synthesizer, Unknown type of information 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 


/*
    Set the information for the designated speech channel and selector
*/
long 	SESetSpeechInfo( SpeechChannelIdentifier ssr, unsigned long selector, void* speechInfo )
{

	long error = SynthSimSetSpeechInfo(ssr, selector, speechInfo);

    // This routine should support the following selectors:
    //	soInputMode                   = 'inpt'
    //	soCharacterMode               = 'char'
    //	soNumberMode                  = 'nmbr'
    //	soRate                        = 'rate'
    //	soPitchBase                   = 'pbas'
    //	soPitchMod                    = 'pmod'
    //	soVolume                      = 'volm'
    //	soCommandDelimiter            = 'dlim'
    //	soReset                       = 'rset'
    //	soRefCon                      = 'refc'
    //	soTextDoneCallBack            = 'tdcb'
    //	soSpeechDoneCallBack          = 'sdcb'
    //	soSyncCallBack                = 'sycb'
    //	soErrorCallBack               = 'ercb'
    //	soPhonemeCallBack             = 'phcb'
    //	soWordCallBack                = 'wdcb'
    //	soOutputToFileWithCFURL 	  = 'opaf' 		Pass a CFURLRef to write to this file, NULL to generate sound
	//
	//  Optionally, you may support the following extension:
    //	soSynthExtension              = 'xtnd'
    //
    // NOTE: 	The selector soCurrentVoice is automatically handled by the API,
    // 			and selectors soCurrentA5, soSoundOutput are no longer necessary under Mac OS X.

    // Show info about this call
	OSType selectorAsTypeChars = CFSwapInt32HostToBig(selector);
    printf( "SESetSpeechInfo - speech channel identifier: %d, selector: %.4s, result: %d\n", (int)ssr, (char*)&selectorAsTypeChars, (int)error);

    // This routine normally returns one of the following values:
    //	noErr				0		No error 
    //	paramErr			-50		Invalid value passed in a parameter. Your application passed an invalid parameter for dialog options. 
    //	siUnknownInfoType	-231	Feature not implemented on synthesizer, Unknown type of information 
    //	noSynthFound		-240	Could not find the specified speech synthesizer 

    return error;
} 


