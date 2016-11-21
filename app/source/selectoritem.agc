// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		selectoritem.agc
//		Purpose:	Single Item on selector
//		Date:		10th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Selector item members
// ****************************************************************************************************************************************************************

type SelectorItem 
	isInitialised as integer
	x,y,width,height,depth as integer
	baseID as integer
endtype

// ****************************************************************************************************************************************************************
//																	Create new selector item
// ****************************************************************************************************************************************************************

function SelectorItem_New(sli ref as SelectorItem,width as integer,height as integer,depth as integer,baseID as integer)
	sli.isInitialised = 1	
	sli.width = width
	sli.height = height
	sli.depth = depth 
	sli.baseID = baseID
	CreateSprite(sli.baseID,IMG_FRAME)
	SetSpriteSize(sli.baseID,width,height)
	CreateText(sli.baseID,"")	
	SetTextSize(sli.baseID,width/16.0)
	SelectorItem_Move(sli,-1,500)	
	SelectorItem_SetText(sli,"<undefined>")
	SelectorItem_SetSelected(sli,0)
endfunction

// ****************************************************************************************************************************************************************
//																Delete Selector Item
// ****************************************************************************************************************************************************************

function SelectorItem_Delete(sli ref as SelectorItem)
	if sli.isInitialised <> 0
		sli.isInitialised = 0
		DeleteSprite(sli.baseID)
		DeleteText(sli.baseID)
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move Selctor Item
// ****************************************************************************************************************************************************************

function SelectorItem_Move(sli ref as SelectorItem,x as integer,y as integer)
	if sli.isInitialised <> 0		
		if x < 0 then x = ctl.screenWidth/2
		sli.x = x
		sli.y = y
		SetSpritePositionByOffset(sli.baseID,x,y)
		SetTextPosition(sli.baseID,x-GetTextTotalWidth(sli.baseID)/2,y-GetTextTotalHeight(sli.baseID)/2)
		SetSpriteDepth(sli.baseID,sli.depth)
		SetTextDepth(sli.baseID,sli.depth-1)
	endif
endfunction

// ****************************************************************************************************************************************************************
//														Update Text of selector item
// ****************************************************************************************************************************************************************

function SelectorItem_SetText(sli ref as SelectorItem,txt$ as String)
	if sli.isInitialised <> 0
		txt$ = Lower(txt$)																			// Capitalise individual words
		doNext = 1
		for i = 1 to len(txt$)
			if doNext <> 0 then txt$ = left(txt$,i-1)+Upper(mid(txt$,i,1))+mid(txt$,i+1,999)
			c$ = mid(txt$,i,1)
			doNext = c$ = " " or c$ = "," or c$ = "'" or c$ = chr(34) or c$ = "-"
		next
		SetTextString(sli.baseID,txt$)																// Update text
		SelectorItem_Move(sli,sli.x,sli.y)															// Move as size probably changed
	endif
endfunction

// ****************************************************************************************************************************************************************
//													Set select state of selector item
// ****************************************************************************************************************************************************************

function SelectorItem_SetSelected(sli ref as SelectorItem,isSelected as integer)
	if sli.isInitialised <> 0
		if isSelected
			SetTextColor(sli.baseID,255,64,64,255)
		else
			SetTextColor(sli.baseID,32,64,64,255)
		endif
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Check if selector item clicked
// ****************************************************************************************************************************************************************

function SelectorItem_IsClicked(sli ref as SelectorItem,x as integer,y as integer)
	isHit = GetSpriteHitTest(sli.baseID,x,y)
endfunction isHit
