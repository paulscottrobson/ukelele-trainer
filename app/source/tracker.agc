// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		tracker.agc
//		Purpose:	Bottom tracker bar.
//		Date:		4th November 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

global __TRACKLeft# = 0.0
global __TRACKRight# = 100.0
global __TRACKBall# = 50.0
global __TRACKSprite = 0

// ****************************************************************************************************************************************************************
// 																	Set up trackbar graphics
// ****************************************************************************************************************************************************************

function TRACKInitialise()
	CreateSprite(SPR_TRACKLEFT,IMG_YELLOWSPHERE)
	CreateSprite(SPR_TRACKRIGHT,IMG_YELLOWSPHERE)
	CreateSprite(SPR_TRACKBALL,IMG_GREENSPHERE)
	s = 40
	SetSpriteSize(SPR_TRACKBALL,s-4,s-4)
	SetSpriteSize(SPR_TRACKLEFT,s,s)
	SetSpriteSize(SPR_TRACKRIGHT,s,s)
	SetSpriteDepth(SPR_TRACKBALL,DEPTH_TRACK)
	SetSpriteDepth(SPR_TRACKLEFT,DEPTH_TRACK+1)
	SetSpriteDepth(SPR_TRACKRIGHT,DEPTH_TRACK+1)
	TRACKReposition(0.0)
	CreateSprite(SPR_TRACKBAR,IMG_RECTANGLE)
	SetSpriteSize(SPR_TRACKBAR,ctl.screenWidth-ctl.trackerMargin*2,ctl.screenHeight/70)
	SetSpritePosition(SPR_TRACKBAR,ctl.screenWidth/2-GetSpriteWidth(SPR_TRACKBAR)/2,ctl.trackerY-GetSpriteHeight(SPR_TRACKBAR)/2)
	SetSpriteColor(SPR_TRACKBAR,0,0,0,255)
	SetSpriteDepth(SPR_TRACKBAR,DEPTH_TRACK+2)
endfunction

// ****************************************************************************************************************************************************************
//																			Reset Tracker
// ****************************************************************************************************************************************************************

function TRACKReset()
	__TRACKLeft# = 0
	__TRACKRight# = 100
	__TRACKBall# = 0
	__TRACKSprite = 0
endfunction

// ****************************************************************************************************************************************************************
//												Handle Click (pick up new object to drag)
// ****************************************************************************************************************************************************************

function TRACKClick(x as integer, y as integer,bars as integer,position# as float)
	__TRACKSprite = 0																			// 0 = none, identify object
	if GetSpriteHitTest(SPR_TRACKLEFT,x,y) <> 0 then __TRACKSprite = SPR_TRACKLEFT
	if GetSpriteHitTest(SPR_TRACKRIGHT,x,y) <> 0 then __TRACKSprite = SPR_TRACKRIGHT
	if GetSpriteHitTest(SPR_TRACKBALL,x,y) <> 0 then __TRACKSprite = SPR_TRACKBALL
	if __TRACKSprite = 0 and abs(y-ctl.trackerY) < 32 
		position# = __TRACKGetPos(x) * bars / 100.0 + 1											// Direct click movement
	endif
endfunction position#

// ****************************************************************************************************************************************************************
//															Drag object about
// ****************************************************************************************************************************************************************

function TRACKUpdate(position# as float,bars as integer)
	if GetPointerState() = 0 then __TRACKSprite = 0													// Object released
	if __TRACKSprite <> 0																			// Dragging
		pos# = __TRACKGetPos(GetPointerX())															// Convert to 0-100
		select __TRACKSprite 
			case SPR_TRACKBALL 																		// Ball
				if pos# > __TRACKRight# then pos# = __TRACKRight#									// Cannot go past right
				TRACKReposition(pos#)
				position# = bars * pos# / 100.0 + 1 												// also updates playing position
			endcase
			case SPR_TRACKLEFT 																		// Left
				if pos# > __TRACKRight#-1 then pos# = __TRACKRight# - 1 							// almost reaches right
				__TRACKLeft# = pos#
				TRACKReposition(-1)
			endcase
			case SPR_TRACKRIGHT																		// Right
				if pos# < __TRACKLeft#+1 then pos# = __TRACKLeft# + 1								// almost reaches left
				__TRACKRight# = pos#
				TRACKReposition(-1)
			endcase
		endselect
	endif
	maxPos# = bars * __TRACKRight# / 100.0 + 1														// End of song as defined by right
	if position# >= maxPos# and __TRACKRight# <> 100.0 
		position# = bars * __TRACKLeft# / 100.0 + 1 												// If gone past/reached, go back to the left
	endif
endfunction position#

// ****************************************************************************************************************************************************************
//														Get Left hand track ball position in song
// ****************************************************************************************************************************************************************

function TRACKGetResetPosition(song ref as Song)
	pos# = __TRACKLeft# / 100.0 * song.barCount + 1.0
	if pos# < 1 then pos# = 1
endfunction pos#

// ****************************************************************************************************************************************************************
//																		Reposition sphere objects
// ****************************************************************************************************************************************************************

function TRACKReposition(pos# as float)
	if pos# > 100.0 then pos# = 100.0																// Not off the right
	if pos# >= 0 then __TRACKBall# = pos# 															// -1 doesn't move the position ball
	SetSpritePosition(SPR_TRACKLEFT,__TRACKGetX(__TRACKLeft#)-GetSpriteWidth(SPR_TRACKLEFT)/2,ctl.trackerY-GetSpriteHeight(SPR_TRACKLEFT)/2)
	SetSpritePosition(SPR_TRACKRIGHT,__TRACKGetX(__TRACKRight#)-GetSpriteWidth(SPR_TRACKRIGHT)/2,ctl.trackerY-GetSpriteHeight(SPR_TRACKRIGHT)/2)
	SetSpritePosition(SPR_TRACKBALL,__TRACKGetX(__TRACKBall#)-GetSpriteWidth(SPR_TRACKBALL)/2,ctl.trackerY-GetSpriteHeight(SPR_TRACKBALL)/2)	
endfunction

// ****************************************************************************************************************************************************************
//																		Convert percentage to physical
// ****************************************************************************************************************************************************************

function __TRACKGetX(pos# as float)
	x# = (ctl.screenWidth-ctl.trackerMargin*2) * pos# / 100.0 + ctl.trackerMargin
endfunction x#

// ****************************************************************************************************************************************************************
//																		Convert physical to percentage
// ****************************************************************************************************************************************************************

function __TRACKGetPos(x as integer)
	pos# = 100.0 * (x - ctl.trackerMargin) / (ctl.screenWidth - ctl.trackerMargin * 2)					// Get percentage
	if pos# < 0 then pos# = 0 																			// Force in range 0-100
	if pos# > 100 then pos# = 100
endfunction pos#
