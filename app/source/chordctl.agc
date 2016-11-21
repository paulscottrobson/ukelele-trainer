// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chordctl.agc
//		Purpose:	Chord controller
//		Date:		4th September 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Set up Chord initial state
// ****************************************************************************************************************************************************************

function CHCTLSetup(song ref as Song,cdNow ref as ChordView,cdNext ref as ChordView)
	if song.chordCount = 0 then exitfunction
	CHORDSetup(cdNow,20,130,320,120,600,"Now")
	CHORDSetup(cdNext,420,130,320,120,700,"Next")
	CHORDSetAlpha(cdNow,0)
	CHORDSetAlpha(cdNext,0)
	if song.chordCount > 0 
		CHCTLSetChord(song,1,cdNow,cdNext)
	endif	
	__CHCTLPendingUpdate = 0
	__CHCTLUpdateStartTime = 0
endfunction

// ****************************************************************************************************************************************************************
//																	Update chord from position
// ****************************************************************************************************************************************************************

global __CHCTLPendingUpdate as integer 																								// Pending update
global __CHCTLUpdateStartTime as integer 																							// Start time of update
global __CHCTLUpdateMS as integer = 450 																							// TIme for total update.

function CHCTLUpdate(song ref as Song,position# as float,lastPosition# as float,cdNow ref as ChordView,cdNext ref as ChordView)
	if song.chordCount = 0 then exitfunction
	for i = 1 to song.chordCount		
		t# = song.chordEvents[i].time / 1000.0
		if t# >= lastPosition# and t# < position# 
			//CHCTLSetChord(song,i,cdNow,cdNext)			
			__CHCTLUpdateStartTime = GetMilliseconds()																				// Update now.
			__CHCTLPendingUpdate = i
		endif
	next i			
	if __CHCTLUpdateStartTime <> 0
		t = GetMilliseconds()
		t = t - __CHCTLUpdateStartTime																								// Ms elapsed
		if t > __CHCTLUpdateMS/2 																									// 2nd half e.g. opacity up.
			t = __CHCTLUpdateMS - t 																								// Flip it
			if __CHCTLPendingUpdate > 0  																							// Check update due.
				CHCTLSetChord(song,__CHCTLPendingUpdate,cdNow,cdNext)
				__CHCTLPendingUpdate = 0
			endif
		endif
		alpha = 255-t * 255 / (__CHCTLUpdateMS/2)																					// Set alpha
		CHORDSetAlpha(cdNow,alpha)
		CHORDSetAlpha(cdNext,alpha)
		if t > __CHCTLUpdateMS then __CHCTLUpdateStartTime = 0																		// Set alpha over
	endif
	
endfunction

// ****************************************************************************************************************************************************************
//														Set current displayed chord if any.
// ****************************************************************************************************************************************************************

function CHCTLSetChord(song ref as Song,n as integer,cdNow ref as ChordView,cdNext ref as ChordView)
	if song.chordCount = 0 then exitfunction
	CHORDSetAlpha(cdNow,255)
	CHORDSetChord(cdNow,song.chordEvents[n])
	CHORDSetAlpha(cdNext,255)
	if n < song.chordCount
		CHORDSetChord(cdNext,song.chordEvents[n+1])
	else
		CHORDSetChord(cdNext,song.chordEvents[n])
	endif
endfunction
