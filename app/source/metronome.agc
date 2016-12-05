// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		metronome.agc
//		Purpose:	Metronome code
//		Date:		31st October 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Set up metronome
// ****************************************************************************************************************************************************************

function METInitialise()
	CreateSprite(SPR_METRONOME,IMG_METRONOME)
	SetSpriteDepth(SPR_METRONOME,DEPTH_METRONOME)
	SetSpriteOffset(SPR_METRONOME,GetSpriteWidth(SPR_METRONOME)*0.5,GetSpriteHeight(SPR_METRONOME)*0.9)
	SetSpritePositionByOffset(SPR_METRONOME,ctl.screenWidth*0.85,ctl.fretY)
	CreateText(TXT_BPM,"xxx")
	SetTextDepth(TXT_BPM,DEPTH_METRONOME-1)
	SetTextSize(TXT_BPM,ctl.screenWidth/24)
	SetTextColor(TXT_BPM,0,0,0,128)
	METSetTempo(100)
endfunction

function METSetTempo(percent as integer)
	SetTextString(TXT_BPM,str(percent)+" %")
	SetTextPosition(TXT_BPM,ctl.screenWidth*0.85-GetTextTotalWidth(TXT_BPM)/2,ctl.fretY-GetSpriteHeight(SPR_METRONOME)*0.8)
endfunction

// ****************************************************************************************************************************************************************
//																Update and sound metronome
// ****************************************************************************************************************************************************************

function METUpdate(song ref as Song,position# as float,lastPosition# as float)
		
	if floor(position#*song.beats) <> floor(lastPosition#*song.beats) and ctl.metronomeOn <> 0
		if mod(floor(position#*song.beats),song.beats) = 0 then vol = 100 else vol = 33
		PlaySound(SND_METRONOME,vol)
	endif
	position# = position# * song.beats / 2
	lastPosition# = lastPosition# * song.beats / 2	
	pos# = (position# - floor(lastPosition#)) * 1000
	if pos# > 500 then pos# = 1000-pos#
	pos# = (pos# - 250.0) / 250.0
	SetSpriteAngle(SPR_METRONOME,pos#*30)
endfunction
