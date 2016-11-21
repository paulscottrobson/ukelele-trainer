// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		musicselector.agc
//		Purpose:	Music Selector
//		Date:		10th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Selector members
// ****************************************************************************************************************************************************************

type MusicSelector
	isInitialised as integer																		// Is initialised
	x,y,iWidth,iHeight,depth as integer																// X Y position of top, width and height of individuals,depth
	vCount,vSpacing as integer 																		// Number of items visible and gaps between them.
	itemList$ as string 																			// ; seperated list of items.
	vItems as SelectorItem[1]																		// Visible item units
	totalCount as integer 																			// Total number of items
	scrollPosition as integer 																		// Scrolling position
	selected as integer 																			// Current selected,0 = none
	hasScrollBar as integer 																		// True if scroll bar
	baseID as integer 																				// Base ID
	scrollWidth as integer 																			// Width of scroll bar.
endtype

// ****************************************************************************************************************************************************************
//																	Create new selector
// ****************************************************************************************************************************************************************

function MusicSelector_New(mse ref as MusicSelector,itemList$ as String,iWidth as integer,iHeight as integer,depth as integer,vCount as integer,vSpacing as integer,baseID as integer)
	mse.isInitialised = 1	
	mse.iWidth = iWidth
	mse.iHeight = iHeight
	mse.depth = depth 
	mse.vCount = vCount
	mse.totalCount = CountStringTokens(itemList$,";")												// Calc how many items
	if mse.totalCount < mse.vCount then mse.vCount = mse.totalCount 								// If more selector boxes than needed reduce visible count
	mse.vSpacing = vSpacing
	mse.itemList$ = itemList$
	mse.vItems.length = vCount
	mse.scrollPosition = 0
	mse.hasScrollBar = (mse.totalCount > mse.vCount)												// Does it have scroll bar
	mse.baseID = baseID
	mse.scrollWidth = 0
	if mse.hasScrollBar then mse.scrollWidth = iWidth / 16
	mse.selected = 1
	for i = 1 to mse.vCount
		SelectorItem_New(mse.vItems[i],iWidth,iHeight,depth,baseID+i+10)
	next i
	if mse.hasScrollBar <> 0
		CreateSprite(baseID,IMG_STRING)																// Use the string as the scroll bar
		SetSpriteAngle(baseID,90)
		SetSpriteColor(baseID,0,0,0,255)
		CreateSprite(baseID+1,IMG_GREENSPHERE)
	endif
	_MusicSelector_UpdateText(mse)	
	SelectorItem_SetSelected(mse.vItems[1],1)
	MusicSelector_Move(mse,-1,-1)																	// Move it.
endfunction

// ****************************************************************************************************************************************************************
//																	   Delete Selector
// ****************************************************************************************************************************************************************

function MusicSelector_Delete(mse ref as MusicSelector)
	if mse.isInitialised <> 0
		mse.isInitialised = 0
		for i = 1 to mse.vCount
			SelectorItem_Delete(mse.vItems[i])
		next i
		DeleteText(mse.baseID)
		if mse.hasScrollBar <> 0
			DeleteSprite(mse.baseID)
			DeleteSprite(mse.baseID+1)
		endif
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move Selctor Item
// ****************************************************************************************************************************************************************

function MusicSelector_Move(mse ref as MusicSelector,x as integer,y as integer)
	if mse.isInitialised <> 0		
		totalHeight = mse.iHeight*(mse.vCount-1) + mse.vSpacing*(mse.vCount-1)
		if x < 0 then x = ctl.screenWidth/2 - mse.scrollWidth / 2
		if y < 0 then y = ctl.screenHeight/2 - totalHeight / 2
		mse.x = x
		mse.y = y
		for i = 1 to mse.vCount
			SelectorItem_Move(mse.vItems[i],x,y)
			SelectorItem_SetSelected(mse.vItems[i],(i + mse.scrollPosition) = mse.selected)
			y = y + mse.iHeight + mse.vSpacing
		next i
		if mse.hasScrollBar 
			xc = mse.x+mse.iWidth/2+mse.scrollWidth/2
			SetSpritePositionByOffset(mse.baseID,xc,mse.y+totalHeight / 2)
			SetSpriteSize(mse.baseID,totalHeight,mse.scrollWidth / 5)
			SetSpriteDepth(mse.baseID,mse.depth)
			SetSpriteSize(mse.baseID+1,mse.scrollWidth*0.8,mse.scrollWidth*0.8)
			SetSpriteDepth(mse.baseID+1,mse.depth)
			y = mse.y + totalHeight * mse.scrollPosition / (mse.totalCount - mse.vCount)
			SetSpritePosition(mse.baseID+1,xc-GetSpriteWidth(mse.baseID+1)/2,y-GetSpriteHeight(mse.baseID+1)/2)
		endif
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Update text in a selector
// ****************************************************************************************************************************************************************

function _MusicSelector_UpdateText(mse ref as MusicSelector)
	for i = 1 to mse.vCount
		item$ = GetStringToken(mse.itemList$,";",i+mse.scrollPosition)
		if left(item$,1) = "(" and right(item$,1) = ")"
			item$ = mid(item$,2,len(item$)-2)
			if right(item$,8) = "_private" then item$ = left(item$,len(item$)-8)
			if item$ = ".." then item$ = "Parent Folder" else item$ = "'"+item$+"' Folder"
		endif
		SelectorItem_SetText(mse.vItems[i],item$)
		sel = (i+mse.scrollPosition) = mse.selected
		SelectorItem_SetSelected(mse.vItems[i],sel)
	next i
endfunction

// ****************************************************************************************************************************************************************
//														Run selector, returns text of selected
// ****************************************************************************************************************************************************************

function MusicSelector_Select(mse as MusicSelector)
	hasSelected = 0
	while hasSelected = 0
		selectResult$ = GetStringToken(mse.itemList$,";",mse.selected)								// Get the result
		if GetRawKeyPressed(27) then End
		if GetRawKeyPressed(KEY_SPACE) or GetRawKeyPressed(KEY_ENTER) then hasSelected = 1			// Exit if selected.
		offset = 0
		if GetRawKeyPressed(KEY_UP) then offset = -1												// Handle keys moving selected
		if GetRawKeyPressed(KEY_DOWN) then offset = 1
		if GetRawKeyPressed(KEY_PAGEUP) then offset = -mse.vCount
		if GetRawKeyPressed(KEY_PAGEDOWN) then offset = mse.vCount
		if GetRawKeyPressed(KEY_HOME) then offset = -mse.totalCount
		if GetRawKeyPressed(KEY_END) then offset = mse.totalCount
		
		if offset <> 0  																			// Moving position
			newSelected = mse.selected + offset														// Calculate new select
			if newSelected < 1 then newSelected = 1													// Check in range
			if newSelected > mse.totalCount then newSelected = mse.totalCount
			if newSelected <> mse.selected 															// Actually changed ?
				offsetInItems = newSelected-mse.scrollPosition
				if offsetInItems >=1 and offsetInItems <= mse.vCount									// No Scroll
					SelectorItem_SetSelected(mse.vItems[mse.selected-mse.scrollPosition],0)			// Deselect
					SelectorItem_SetSelected(mse.vItems[newSelected-mse.scrollPosition],1)			// Reselect
				endif
				mse.selected = newSelected
				if offsetInItems < 1 then _MusicSelector_ScrollTo(mse,newSelected-1) 					
				if offsetInItems > mse.vCount then _MusicSelector_ScrollTo(mse,newSelected-(mse.vCount))
			endif
		endif
		
		if GetPointerPressed() <> 0 																// Mouse click
			x = GetPointerX()
			y = GetPointerY()
			for i = 1 to mse.vCount																	// Check if any boxes clicked
				if GetSpriteHitTest(mse.baseID+i+10,x,y) <> 0
					selectResult$ = GetStringToken(mse.itemList$,";",i+mse.scrollPosition)			// If so set result allowing for scroll position
					hasSelected = 1																	// And exit					
				endif				
			next i
		endif
		if GetPointerState() <> 0 and mse.hasScrollBar
			x = GetPointerX()
			y = GetPointerY()
			y = y - GetSpriteY(mse.baseID)+GetSpriteWidth(mse.baseID)/2								// Offset from top of scroll bar, calculate if hit
			x = x - (mse.x+mse.iWidth/2+mse.scrollWidth/2)
			if y >= 0 and y < GetSpriteWidth(mse.baseID) and abs(x) < mse.scrollWidth/2				// If in range
				pos = y * (mse.totalCount - mse.vCount) / GetSpriteWidth(mse.baseID)				// Reposition scroll bar
				_MusicSelector_ScrollTo(mse,pos)
			endif			
		endif
		//if GetRawKeyPressed(27) <> 0 then End
		Sync()
	endwhile
	
endfunction selectResult$

// ****************************************************************************************************************************************************************
//															Scroll so the given item is the top item
// ****************************************************************************************************************************************************************

function _MusicSelector_ScrollTo(mse ref as MusicSelector,newScroll as integer)
	//debug = debug + str(newScroll)+";"
	mse.scrollPosition = newScroll
	_MusicSelector_UpdateText(mse)
	MusicSelector_Move(mse,mse.x,mse.y)
endfunction
	
