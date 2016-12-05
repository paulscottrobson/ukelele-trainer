// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		main.agc
//		Purpose:	Main program
//		Date:		2nd November 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

#include "source\common.agc"																		// Source files.
#include "source\drawing.agc"
#include "source\manager.agc"
#include "source\song.agc"
#include "source\panel.agc"
#include "source\metronome.agc"
#include "source\selectoritem.agc"
#include "source\musicselector.agc"
#include "source\tracker.agc"
#include "source\player.agc"
#include "source\io.agc"
#include "source\select.agc"
#include "source\chord.agc"
#include "source\chordctl.agc"

#constant BUILD_NUMBER	(17)
#constant BUILD_DATE 	("27 Nov 2016")

COMSetup()																							// Set up common constants etc
PANELInitialise()																					// Initialise the panel
TRACKInitialise()																					// Initialise drag track
METInitialise()																						// Initialise metronome
DRAWFretboard()																						// Draw the Fretboard
SELSelectAndRun()
//PlayOneSong("test2.music")

// ****************************************************************************************************************************************************************
//																			Play a single song
// ****************************************************************************************************************************************************************

function PlayOneSong(songFile$ as String)

	song as Song
	SONGLoad(song,songFile$)																		// Load in the song
	TRACKReset()																					// Reset tracker
	PLAYSetup(song)																					// Set up playback
	position# = 1.0																					// Position in song
	lastPosition# = 0.0
	lastTime = GetMilliseconds()																	// Time last loop
	exitFlag = 0																					// Set when completed
	ctl.tempoPercent = 100 																			// Clear any tempo adjustments
	cdNow as ChordView																				// Set up chords
	cdNext as ChordView
	CHCTLSetup(song,cdNow,cdNext)
	
//	for i = 1 to 2
//		debug$ = debug$ + __SONGBarToString(song,song.bars[i]) + "&"
//	next i
	
//	for n = 0 to song.barCount
//		DRAWMoveBar(song,n+1,n*ctl.barWidth+ctl.barX)
//	next n
		
	while GetRawKeyState(27) = 0 and exitFlag = 0

		elapsed# = (GetMilliseconds() - lastTime) / 1000.0											// Elapsed time in seconds
		lastTime = GetMilliseconds()																// Track last time
		tempo = song.tempo 																			// Work out tempo, minimal 30 bps
		if tempo < 30 then tempo = 30
		beats# = tempo / 60.0  														 				// Convert beats / minute to beats / second.
		beats# = beats# / song.beats 																// Now bars per second
		beats# = beats# * ctl.tempoPercent / 100.0 													// Scale for tempo
		METSetTempo(ctl.tempoPercent)
		if ctl.isRunning
			position# = position# + beats# * elapsed# 												// Adjust position if not paused
		endif
		//debug$ = str(position#)
		if position# > song.barCount + 1 then position# = song.barCount + 1 						// Cannot go too far
		if position# < 1.0 then position# = 1.0
		TRACKReposition((position# - 1.0) * 100.0 / song.barCount)									// Position tracker bar
		position# = PANELClick(song,GetPointerPressed(),GetPointerX(),GetPointerY(),position#)
		if position# = 1.0 and song.chordCount > 0 then CHCTLSetChord(song,1,cdNow,cdNext)			// Reset to start, set up chord

		if position# < 0 																			// Exit if position set to -1.
			position# = 1
			exitFlag = 1
		endif
		
		posOld# = position#
		if GetPointerPressed() <> 0 																// Handle mouse clicks
			position# = TRACKClick(GetPointerX(),GetPointerY(),song.barCount,position#)
		endif
		position# = TRACKUpdate(position#,song.barCount)											// Update track mouse drag
		METUpdate(song,position#,lastPosition#)
		PLAYUpdate(song,position#,lastPosition#)
		if position# = posOld#
			CHCTLUpdate(song,position#,lastPosition#,cdNow,cdNext)
		else
			CHCTLUpdate(song,position#,0,cdNow,cdNext)
		endif

		MGRMove(song,position#,lastPosition#)														// Move to current position
		lastPosition# = position#

		//ShowDebug()
		Sync()
	endwhile
	
	DRAWEraseAll(song)
	CHORDDelete(cdNow)
	CHORDDelete(cdNext)
	while GetRawKeyState(27) <> 0
		Sync()
	endwhile
endfunction

// ****************************************************************************************************************************************************************
//
//	27/11/16: 	Change metronome controls to percentage of provided speed.
//
// ****************************************************************************************************************************************************************
