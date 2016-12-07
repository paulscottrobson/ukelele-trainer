// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chord.agc
//		Purpose:	Chord Viewer
//		Date:		4th November 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

#constant CHORD_CHROM 	(7)

// ****************************************************************************************************************************************************************
//																	Create a chord display
// ****************************************************************************************************************************************************************

function CHORDSetup(cv ref as ChordView,x as integer,y as integer,width as integer,height as integer,id as integer,label as String)
	cv.x = x
	cv.y = y
	cv.width = width
	cv.height = height
	cv.id = id
	cv.label = label
	CreateSprite(id,IMG_RECTANGLE)																		// Background
	SetSpritePosition(id,x,y)
	SetSpriteSize(id,width,height)
	SetSpriteColor(id,64,64,64,255)
	SetSpriteDepth(id,DEPTH_CHORD+3)
	CreateText(id,cv.label+"XXX")																		// Label
	SetTextDepth(id,DEPTH_CHORD+3)
	SetTextSize(id,width/9.0)
	SetTextColor(id,0,0,0,255)
	SetTextPosition(id,x,y-GetTextTotalHeight(id))
	for i = 1 to 4																						// Strings
		y1 = __CHORDY(cv,i)
		CreateSprite(id+i,IMG_STRING)
		SetSpriteSize(id+i,width,height/24)
		SetSpriteDepth(id+i,DEPTH_CHORD+1)
		SetSpritePosition(id+i,cv.x,y1-GetSpriteHeight(id+i)/2)
		CreateSprite(id+i+40,IMG_REDSPHERE)
		SetSpritePosition(id+i+40,x+width/2,y1)
		sz = height*20/100
		SetSpriteSize(id+i+40,sz,sz)
		SetSpriteDepth(id+i+40,DEPTH_CHORD)
	next i
	for i = 0 to CHORD_CHROM
		CreateSprite(id+10+i,IMG_BAR)
		if i <> CHORD_CHROM then w = 64 else w = 16
		SetSpriteSize(id+10+i,width/w,height)
		SetSpritePosition(id+10+i,x+width*i/CHORD_CHROM,cv.y)
		SetSpriteDepth(id+10+i,DEPTH_CHORD+2)
	next i
endfunction

// ****************************************************************************************************************************************************************
//																		Delete a chord display
// ****************************************************************************************************************************************************************

function CHORDDelete(cv ref as ChordView)
	DeleteSprite(cv.id)
	DeleteText(cv.id)
	for i = 1 to 4
		DeleteSprite(cv.id+i)
		DeleteSprite(cv.id+i+40)
	next i
	for i = 0 to CHORD_CHROM
		if GetSpriteExists(cv.id+10+i) <> 0 then DeleteSprite(cv.id+10+i)
	next i
endfunction

// ****************************************************************************************************************************************************************
//																	Set a chord display to a note
// ****************************************************************************************************************************************************************

function CHORDSetChord(cv ref as ChordView,cev ref as ChordEvent)
	for s = 1 to 4
		SetSpriteVisible(cv.id+s+40,cev.fret[s] > 0 and cev.fret[s] <= CHORD_CHROM)
		x = cv.x + cv.width - cv.width * cev.fret[s] / CHORD_CHROM + GetSpriteWidth(cv.id+s+40)/2
		y = __CHORDY(cv,s) - GetSpriteHeight(cv.id+s+40)/2
		SetSpritePosition(cv.id+s+40,x,y)
		SetSpriteVisible(cv.id+s,cev.fret[s] <> 99)
	next s
	SetTextString(cv.id,cv.label+" : "+upper(left(cev.name$,1))+lower(mid(cev.name$,2,99)))
endfunction

// ****************************************************************************************************************************************************************
//																		Get string vertical
// ****************************************************************************************************************************************************************

function __CHORDY(cv ref as ChordView,y as integer)
	y = cv.y + cv.height / 2 + (y - 2.5) * cv.height * 25 / 100
endfunction y

// ****************************************************************************************************************************************************************
//																			Set Chord Alpha
// ****************************************************************************************************************************************************************

function CHORDSetAlpha(cv ref as ChordView,alpha as integer)
	SetSpriteColorAlpha(cv.id,alpha)
	SetTextColorAlpha(cv.id,alpha)
	for i = 1 to 4
		SetSpriteColorAlpha(cv.id+i,alpha)
		if i < 4 then SetSpriteColorAlpha(cv.id+i+40,alpha)
	next i
	for i = 0 to CHORD_CHROM
		if GetSpriteExists(cv.id+10+i) <> 0 then SetSpriteColorAlpha(cv.id+10+i,alpha)
	next i
endfunction
