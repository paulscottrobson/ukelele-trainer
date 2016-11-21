// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		drawing.agc
//		Purpose:	Drawing fretboard components
//		Date:		28th October 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

function DRAWFretboard()
	CreateSprite(SPR_FRETBOARD,IMG_FRETBOARD)															// Create and draw Fretboard
	SetSpriteDepth(SPR_FRETBOARD,DEPTH_FRETBOARD+5)
	SetSpriteSize(SPR_FRETBOARD,ctl.screenWidth,ctl.fretHeight)
	SetSpritePosition(SPR_FRETBOARD,0,ctl.fretY)
	for s = 1 to 4																						// Draw 4 strings (2 melody)
		CreateSprite(SPR_STRING+s,IMG_STRING)
		SetSpriteDepth(SPR_STRING+s,DEPTH_FRETBOARD+4)
		SetSpriteSize(SPR_STRING+s,ctl.screenWidth,ctl.screenHeight*1/100+s*2)
		SetSpritePosition(SPR_STRING+s,0,__DRAWGetStringY(s))
	next s
	CreateSprite(SPR_BALL,IMG_REDSPHERE)																// Create bouncing ball sprite
	sz = ctl.screenHeight / 25
	SetSpriteSize(SPR_BALL,sz,sz)
	SetSpriteDepth(SPR_BALL,DEPTH_BALL)
	SetSpritePosition(SPR_BALL,ctl.barX-GetSpriteWidth(SPR_BALL)/2,0)
endfunction

// ****************************************************************************************************************************************************************
//																		Draw a bar on the screen
// ****************************************************************************************************************************************************************

function __DRAWDrawBar(song ref as Song,bar as integer)
	if song.bars[bar].isDrawn <> 0 then exitfunction													// Already drawn
	song.bars[bar].isDrawn = 1
	baseID = song.bars[bar].baseID

	CreateSprite(baseID,IMG_BAR)																		// s+0 is the bar
	SetSpriteDepth(baseID,DEPTH_BAR+8)
	SetSpriteSize(baseID,ctl.screenWidth/128,ctl.fretHeight*84/100)

	if song.barCount = bar 																				// s+1 is the trailing bar, last only.
		CreateSprite(baseID+1,IMG_BAR)															
		SetSpriteDepth(baseID+1,DEPTH_BAR+8)
		SetSpriteSize(baseID+1,ctl.screenWidth/128,ctl.fretHeight*84/100)
	endif
	CreateText(baseID,song.bars[bar].lyric$)															// t+0 is the lyric
	SetTextDepth(baseID,DEPTH_BAR)
	SetTextColor(baseID,0,0,0,255)
	SetTextSize(baseID,song.lyricSize#)
	
	for n = 1 to song.bars[bar].noteCount 			
				
		if song.bars[bar].isStrummed = 0													
			for s = 1 to song.strings																	// Note boxes
				id = baseID + n * 10 + s																	
				if song.bars[bar].notes[n].fret[s] <> 99
					CreateSprite(id,IMG_NOTEBOX)														// s+0 is the box
					CreateText(id,"6+")																	// t+0 is the text in it.
					SetSpriteDepth(id,DEPTH_BAR+1)
					SetSpriteFlip(id,0,song.bars[bar].notes[n].isUpStroke <> 0)
					SetTextDepth(id,DEPTH_BAR)
					sz# = ctl.barWidth / 9																// Size of box
					SetSpriteSize(id,sz#,sz#*5/4)									
					SetTextColor(id,255,255,255,255)
					SetTextSize(id,sz#*0.8)																// Size of text
					fret = song.bars[bar].notes[n].fret[s]												// Chromatic note
					s$ = str(floor(fret))																// As a string, integer part
					SetTextString(id,s$)	
					col = floor(fret)
					__DRAWColourSprite(id,col)
				endif
			next s
		else																							// Single arrow for strum
			id = baseID + n * 10
			CreateSprite(id,IMG_ARROW)
			SetSpriteSize(id,ctl.barWidth/8,ctl.fretHeight*70/100)
			SetSpriteDepth(id,DEPTH_BAR+1)
			SetSpriteFlip(id,0,1)
			if song.bars[bar].notes[n].isUpStroke <> 0 													// Handle up/toward strum
				SetSpriteFlip(id,0,0)
				SetSpriteSize(id,ctl.barWidth/8,ctl.fretHeight*55/100)
			endif
			s$ = song.bars[bar].notes[n].name$															// Set name
			s$ = Upper(left(s$,1))+Lower(mid(s$,2,99))
			CreateText(id,s$)
			SetTextDepth(id,DEPTH_BAR)
			SetTextColor(id,255,255,255,255)
			sz# = ctl.barWidth / 8
			SetTextSize(id,sz#*0.8)																		// Size of text
			__DRAWColourSprite(id,asc(s$))
		endif
	next n
	
	for n = 0 to song.bars[bar].noteCount 																// Sine curves
		id = baseID + n + 600
		if n = 0 then xStart = 0 else xStart = song.bars[bar].notes[n].time 							// Do start time
		if n = song.bars[bar].noteCount then xEnd = 1000 else xEnd = song.bars[bar].notes[n+1].time		// Do end time
		if xStart <> xEnd 																				// Is there a step here
			w = ctl.barWidth * (xEnd-xStart) / 1000 													// Get curve size
			if xEnd-xStart > 240 then img = IMG_SINECURVE_WIDE else img = IMG_SINECURVE
			CreateSprite(id,img)
			SetSpriteSize(id,w,ctl.sineHeight)	
			SetSpriteDepth(id,DEPTH_CURVE)
		endif
	next n
	
endfunction

// ****************************************************************************************************************************************************************
//																		Erase a bar on the screen
// ****************************************************************************************************************************************************************

function __DRAWEraseBar(song ref as Song,bar as integer)
	if song.bars[bar].isDrawn = 0 then exitfunction														// Not drawn
	song.bars[bar].isDrawn = 0
	baseID = song.bars[bar].baseID

	DeleteSprite(baseID)																				// s+0 is the bar
	DeleteText(baseID)																					// t+0 is the lyric
	if song.barCount = bar then DeleteSprite(baseID+1)
	
	for n = 1 to song.bars[bar].noteCount 																							

		if song.bars[bar].isStrummed = 0
			for s = 1 to song.strings																	// Note boxes
				if song.bars[bar].notes[n].fret[s] <> 99
					id = baseID + n * 10 + s
					DeleteSprite(id)
					DeleteText(id)
				endif
			next s
		else																							// Strum displayed as arrow
			id = baseID + n * 10
			DeleteSprite(id)
			DeleteText(id)
		endif
	next n

	for n = 0 to song.bars[bar].noteCount 																// Sine curves
		id = baseID + n + 600
		if GetSpriteExists(id) then DeleteSprite(id)
	next n
	
endfunction

// ****************************************************************************************************************************************************************
//																		 Move a bar on the screen
// ****************************************************************************************************************************************************************

function DRAWMoveBar(song ref as Song,bar as integer,x as integer)
	if bar < 1 or bar > song.barCount then exitfunction 												// Not a valid bar
	
	if x < -(ctl.barWidth + 32)																			// Scrolled off the left ?
		__DRAWEraseBar(song,bar)																		// Erase it.
		exitfunction 																					// And exit.
	endif
	
	if song.bars[bar].isDrawn = 0 																		// Not drawn
		__DRAWDrawBar(song,bar) 																		// then draw it
	endif
	
	baseID = song.bars[bar].baseID
	SetSpritePosition(baseID,x-GetSpriteWidth(baseID)/2,ctl.fretY+ctl.fretHeight/2-GetSpriteHeight(baseID)/2) // Position bar marker (+0)
	if bar = song.barCount
		SetSpritePosition(baseID+1,x+ctl.barWidth-GetSpriteWidth(baseID)/2,ctl.fretY+ctl.fretHeight/2-GetSpriteHeight(baseID)/2) 
	endif

	SetTextPosition(baseID,x+ctl.barWidth/2-GetTextTotalWidth(baseID)/2,ctl.fretY+ctl.fretHeight)
	
	for n = 1 to song.bars[bar].noteCount 												
		xc = x + song.bars[bar].notes[n].time * ctl.barWidth / 1000 									// Base position

		if song.bars[bar].isStrummed = 0
			for s = 1 to song.strings																		// Note boxes
				yc = __DRAWGetStringY(s)
				id = baseID + n * 10 + s
				if song.bars[bar].notes[n].fret[s] <> 99
					if song.bars[bar].notes[n].isUpStroke then p = 50 else p = 50
					SetSpritePosition(id,xc-GetSpriteWidth(id)/2,yc-GetSpriteHeight(id)*p/100)
					SetTextPosition(id,xc-GetTextTotalWidth(id)/2,yc-GetTextTotalHeight(id)/2)
				endif
			next s
		else																							// Strum
			id = baseID + n * 10
			yc = ctl.fretY + ctl.fretHeight / 2
			SetSpritePosition(id,xc-GetSpriteWidth(id)/2,yc-GetSpriteHeight(id)/2)
			SetTextPosition(id,xc-GetTextTotalWidth(id)/2,yc-GetTextTotalHeight(id)/2)
		endif
	next n

	for n = 0 to song.bars[bar].noteCount 																// Sine curves
		id = baseID + n + 600
		if GetSpriteExists(id) 
			if n = 0 then xc = 0 else xc = song.bars[bar].notes[n].time 
			xc = xc * ctl.barWidth / 1000 + x
			SetSpritePosition(id,xc,ctl.sineY-GetSpriteHeight(id))
		endif
	next n
	
	song.bars[bar].xPosition = x																		// Save X position	
endfunction

// ****************************************************************************************************************************************************************
//																			Erase all bar stuff
// ****************************************************************************************************************************************************************

function DRAWEraseAll(song ref as Song)
	for bar = 1 to song.barCount
		if song.bars[bar].isDrawn <> 0 then __DRAWEraseBar(song,bar)
	next bar
endfunction


// ****************************************************************************************************************************************************************
//																	Get String Horizontal position
// ****************************************************************************************************************************************************************

function __DRAWGetStringY(s as integer)
	y = ctl.fretY + ctl.fretHeight / 2																	// Work out centre
	if ctl.flipFretboard <> 0 then flip = -1 else flip = 1 												// Flip Fretboard
	y = y - (s - 2.5) * flip * ctl.fretHeight * 20 / 100													// Adjust by fret
endfunction y
	
// ****************************************************************************************************************************************************************
//													Colour a sprite from the set of colours
// ****************************************************************************************************************************************************************

function __DRAWColourSprite(id as integer,colour as integer)
	col$ = COLOUR_SET																		// List of possible colours
	p = mod(colour,len(col$)/4) * 4 + 2														// Work out which to use
	SetSpriteColorRed(id,Val(mid(col$,p+0,1),16)*15+15)										// And colour the sprite
	SetSpriteColorGreen(id,Val(mid(col$,p+1,1),16)*15+15)
	SetSpriteColorBlue(id,Val(mid(col$,p+2,1),16)*15+15)
endfunction
