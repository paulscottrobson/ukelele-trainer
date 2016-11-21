// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		select.agc
//		Purpose:	Main program
//		Date:		1st September 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																Directory/File Selector
// ****************************************************************************************************************************************************************

function SELSelectAndRun()
	
	currentDir$ = ":"																					// Root directory
	ms as MusicSelector																					// Music selector structure
	sort$ as string[1]
	
	while 1 = 1																							// Forever
		content$ = IOGetDirectory(currentDir$)															// Read directory
		sort$.length = CountStringTokens(content$,";")													// Set up sorting array and fill it.
		for i = 1 to sort$.length
			sort$[i] = GetStringToken(content$,";",i)													
			if left(sort$[i],1) <> "*" 																	// Filenames preceded with @ to sort after *
				p = FindString(sort$[i]," ")
				a = asc(sort$[i])
				if p > 0 and a >= 48 and a < 58 then sort$[i] = left("       ",5-p)+sort$[i]			// Make it sort numerically.
				sort$[i] = "@"+sort$[i]
			endif
		next i
		if currentDir$ <> ":"																			// Add parent directory if required
			sort$.length = sort$.length + 1
			sort$[sort$.length] = "*.."
		endif
		sort$.sort()																					// Sort it.
		content$ = ""																					// Rebuild sorted list.
		for i = 1 to sort$.length
			if i > 1 then content$ = content$ + ";"	
			if left(sort$[i],1) = "@"																	// Filename, add filename without music
				content$ = content$ + TrimString(mid(sort$[i],2,len(sort$[i])-7)," ")
			else
				content$ = content$ + "("+TrimString(mid(sort$[i],2,999)," ")+")"						// Directory
			endif
		next i			
		MusicSelector_New(ms,content$,ctl.screenWidth-128,ctl.screenHeight/10,10,8,6,30000)				// Create Selector
		n$ = MusicSelector_Select(ms)																	// Pick item
		MusicSelector_Delete(ms)																		// Delete
		if left(n$,1) = "("																				// Picked a directory ?
			if n$ = "(..)"																				// Parent directory ?
				currentDir$ = left(currentDir$,len(currentDir$)-1)										// Remove trailing colon
				n = FindStringReverse(currentDir$,":")													// Find one to go back to
				currentDir$ = left(currentDir$,n)														// And go back to it
			else
				currentDir$ = currentDir$ + mid(n$,2,len(n$)-2)+":"
			endif
		else
			n$ = currentDir$ + n$ + ".music"															// Create file name
			PlayOneSong(n$)																				// Play that song.
		endif
	endwhile
endfunction
