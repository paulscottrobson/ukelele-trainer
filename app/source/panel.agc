// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		panel.agc
//		Purpose:	Icon Panel
//		Date:		4th November 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

global __PANELItem$ as string = "Rrestart,Sslower,Nnormal,Ffaster,Pplay:stop,Amusic_on:music_off,Mmetronome_on:metronome_off,Qquit"

// ****************************************************************************************************************************************************************
//																	Set up the Panel
// ****************************************************************************************************************************************************************

function PANELInitialise()	
	s = ctl.screenWidth / 14
	for icon = 1 to CountStringTokens(__PANELItem$,",")												// Work through all panel items
		panel$ = GetStringToken(__PANELItem$,",",icon)												// Get panel entry.
		panel$ = mid(panel$,2,9999)																	// Remove key code
		for sel = 1 to CountStringTokens(panel$,":")												// For each option.
			image$ = "i_"+GetStringToken(panel$,":",sel)											// Get image name and load it
			LoadImage(IMG_PANEL+icon*20+sel,GFXDIR+image$+".png")
		next sel
		CreateSprite(SPR_PANEL+icon,IMG_ICONBOX)													// Create object to fit an icon
		SetSpriteSize(SPR_PANEL+icon,s,s)
		CreateSprite(SPR_PANEL+icon+10,IMG_PANEL+icon*20+1)											// Create icon
		SetSpriteSize(SPR_PANEL+icon+10,s*7/10,s*7/10)
		SetSpritePosition(SPR_PANEL+icon,ctl.screenWidth/2-CountStringTokens(__PANELItem$,",")*(s+10)/2+(s+10)*(icon-1)+4,8)
		n = SPR_PANEL+icon
		n1 = SPR_PANEL+icon+10
		SetSpritePosition(SPR_PANEL+icon+10,GetSpriteX(n)+GetSpriteWidth(n)/2-GetSpriteWidth(n1)/2,GetSpriteY(n)+GetSpriteHeight(n)/2-GetSpriteHeight(n1)/2)
	next icon
endfunction

// ****************************************************************************************************************************************************************
//																	Click Panel Item
// ****************************************************************************************************************************************************************

function PANELClick(song ref as Song,click as integer,x as integer,y as integer,position# as float)
	clicked = 0
	icon$ = ""
	if click <> 0
		for icon = 1 to CountStringTokens(__PANELItem$,",")											// Work through all panel items
			if GetSpriteHitTest(SPR_PANEL+icon,x,y) <> 0 then clicked = icon						// Have any been clicked.
		next icon
	endif

	if icon$ = "" and GetKeyboardExists() <> 0														// Check for key.
		for icon = 1 to CountStringTokens(__PANELItem$,",")											// Work through all panel items
			item$ = GetStringToken(__PANELItem$,",",icon)
			if GetRawKeyPressed(asc(item$)) then clicked = icon
		next icon
	endif

	if clicked <> 0 																				// One clicked
		icon$ = mid(GetStringToken(__PANELItem$,",",clicked),2,9999)								// Get the name of the icon
		if FindString(icon$,":") > 0 																// Toggleable item.
			SetSpriteImage(SPR_PANEL+10+clicked,GetSpriteImageID(SPR_PANEL+10+clicked) ~~ 3)
			icon$ = left(icon$,3)+str(GetSpriteImageID(SPR_PANEL+10+clicked) && 1)
		endif
	endif

	
	if icon$ <> ""
		select left(upper(icon$),3)																	// pick what to do
			case "RES"
				position# = TRACKGetResetPosition(song)
			endcase

			case "FAS"
				ctl.tempoAdjust = ctl.tempoAdjust + 10
			endcase

			case "NOR"
				ctl.tempoAdjust = 0
			endcase
					
			case "SLO"
				ctl.tempoAdjust = ctl.tempoAdjust - 10
			endcase
			
			case "PLA"
				ctl.isRunning = right(icon$,1) = "1"
			endcase
			
			case "MET"
				ctl.metronomeOn = right(icon$,1) = "1"
			endcase

			case "MUS"
				ctl.musicOn = right(icon$,1) = "1"
			endcase
			
			case "QUI"
				position# = -1
			endcase
			
		endselect
		//debug$ = debug$ + str(ctl.tempoScalar#) + "&"
	endif
endfunction position#
