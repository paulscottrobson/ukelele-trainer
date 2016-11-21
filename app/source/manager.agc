// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		manager.agc
//		Purpose:	Position Manager
//		Date:		31st October 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//															Move displayed position
// ****************************************************************************************************************************************************************

function MGRMove(song ref as Song,position# as float,lastPosition# as float)
	if position# < lastPosition# or abs(position#-lastPosition#) > 0.3									// Backwards, or large jump
		DRAWEraseAll(song)																				// Clear all off and redraw
	endif
	
	for offset = -2 to 3 																				// Bars to move
		bar = floor(position#) + offset																	// Get Bar.
		xc = ctl.barX + ctl.barWidth * offset 															// Base position
		xc = xc - (position# - floor(position#)) * ctl.barWidth
		DRAWMoveBar(song,bar,xc)
	next offset 
	
	
	offset = (position# - floor(position#)) * 1000														// Position in bar.
	bar = floor(position#)
	if bar <= song.barCount
		for n = 0 to song.bars[bar].noteCount 															// Scan notes
			if n = 0 then xStart = 0 else xStart = song.bars[bar].notes[n].time 						// Do start time
			if n = song.bars[bar].noteCount then xEnd = 1000 else xEnd = song.bars[bar].notes[n+1].time	// Do end time
			if offset >= xStart and offset < xEnd 
				progress# = 1.0 * (offset-xStart) / (xEnd-xStart)
				progress# = sin(progress# * 180)
				progress# = progress# * ctl.sineHeight
				y = ctl.sineY - progress# - GetSpriteHeight(SPR_BALL)
				SetSpritePosition(SPR_BALL,GetSpriteX(SPR_BALL),y)
			endif
		next n
	endif
endfunction
