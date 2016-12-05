// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		player.agc
//		Purpose:	Sound Player
//		Date:		31st October 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

type Channel
	baseSoundID as integer																				// First sound ID (chromatic)
	nextFire as integer																					// Time in milliseconds when it note should be fire (-1 = none pending)
	nextNoteID as integer																				// Sound ID to fire (e.g. fret 1 diatonic would be baseSoundID + 2)
	currentNoteID as integer 																			// Currently played note
endtype

global __PLAYChannels as Channel[4]																		// State of 4 channels (representing 4 strings)

// ****************************************************************************************************************************************************************
//																		Player setup
// ****************************************************************************************************************************************************************

function PLAYSetup(song ref as Song)
	for i = 1 to 99																					// Delete all sounds in use currently
		if GetSoundExists(i) <> 0 then DeleteSound(i)
	next i
	LoadSound(SND_METRONOME,SFXDIR+"metronome.wav")														// Load metronome sound
	for s = 1 to song.strings 																			// For each of 4 strings
		base = (s-1) * 15 + 1
		baseNote = (song.strings-s) * 7+1 	
		for n = 0 to 14 																				// 20 chromatic notes
			LoadSoundOGG(base+n,SFXDIR+str(baseNote+n)+".ogg")
		next n
		__PLAYChannels[s].baseSoundID = base															// Initialise channel records
		__PLAYChannels[s].nextFire = -1
		__PLAYChannels[s].currentNoteID = 0
		//debug$ = debug$ + str(s)+" "+str(base)+"&"
	next s
endfunction

function PLAYUpdate(song ref as Song,position# as float,lastPosition# as float)
	
	bar = floor(position#)																				// Bar checked				
	lastBeat = (position# - floor(position#)) * 1000													// Start of check area
	firstBeat = (lastPosition# - floor(lastPosition#)) * 1000											// End of check region
	if firstBeat > lastBeat then firstBeat = 0 															// If new bar, check from start of the new bar.
	if bar > song.barCount then exitfunction
	
	for n = 1 to song.bars[bar].noteCount																// Check notes in bar to see if one is due 
		time = song.bars[bar].notes[n].time																// Time of note
		if time >= firstBeat and time < lastBeat and ctl.musicOn <> 0									// If in range and actually playing
			for s = 1 to song.strings																	// Work through strings
				chromatic = song.bars[bar].notes[n].fret[s]												// Get chromatic value
				if chromatic <> 99																		// If plucked/strummed.					
					__PLAYChannels[s].nextFire = GetMilliseconds()+(song.strings+1-s)*30				// Fire strings
					__PLAYChannels[s].nextNoteID = chromatic + __PLAYChannels[s].baseSoundID					
					//debug$ = debug$ + str(bar)+" "+str(s)+" "+str(chromatic)+"&"
				endif
			next s
		endif
	next n
	
	tMs = GetMilliseconds()	
	for s = 1 to song.strings																			// Check if each due
		if __PLAYChannels[s].nextFire > 0																// Note pending
			if tMs >= __PLAYChannels[s].nextFire														// Time to fire
				if __PLAYChannels[s].currentNoteID > 0 then StopSound(__PLAYChannels[s].currentNoteID)	// Stop any note on this string
				PlaySound(__PLAYChannels[s].nextNoteID)													// Play note
				__PLAYChannels[s].currentNoteID = __PLAYChannels[s].nextNoteID							// Save current note
				__PLAYChannels[s].nextFire = -1															// No note waiting
			endif
		endif
	next s
endfunction
