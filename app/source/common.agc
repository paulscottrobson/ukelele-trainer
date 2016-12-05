// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		common.agc
//		Purpose:	Constants, Structures, Global Definitions
//		Date:		2nd November 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Constants
// ****************************************************************************************************************************************************************

#constant GFXDIR 	"gfx/" 																				// Graphics here
#constant SFXDIR 	"sfx/"																				// Sound here

#constant SND_METRONOME 	(99)																		// Metronome SFX 

#constant IMG_STRING 		(100) 																		
#constant IMG_GREENSPHERE 	(101)
#constant IMG_FRAME 		(102)																		
#constant IMG_HANDLE 		(103)
#constant IMG_NOTEBOX 		(104)
#constant IMG_FRETBOARD		(105)
#constant IMG_REDSPHERE 	(106)
#constant IMG_SINECURVE		(107)
#constant IMG_SINECURVE_WIDE (108)
#constant IMG_BAR			(109)
#constant IMG_YELLOWSPHERE 	(110)
#constant IMG_RECTANGLE 	(111)
#constant IMG_METRONOME 	(112)
#constant IMG_ICONBOX 		(113)
#constant IMG_ARROW 		(114)
#constant IMG_MSTRING 		(115)

#constant SPR_FRETBOARD		(100)
#constant SPR_STRING 		(101)																		// Allow 9
#constant SPR_BALL 			(110)																		// Bouncy ball sprite
#constant SPR_TRACKBALL		(111)
#constant SPR_TRACKLEFT		(112)
#constant SPR_TRACKRIGHT	(113)
#constant SPR_TRACKBAR 		(114)
#constant SPR_METRONOME 	(115)
#constant TXT_BPM 			(116) 

#constant SPR_PANEL 		(300)																		// 300s are for the panel.
#constant IMG_PANEL 		(300)

#constant SPR_SELECTOR 		(400)	 																	// Selector sprites

#constant DEPTH_BALL 		(40)																		// Bouncy Ball Depth
#constant DEPTH_CURVE		(50)
#constant DEPTH_BAR			(60)																		// Depth of Bar Graphics
#constant DEPTH_TRACK		(70)
#constant DEPTH_FRETBOARD	(80)																		// Fretboard and all other fixed elements
#constant DEPTH_METRONOME	(90)
#constant DEPTH_CHORD 		(60)

#constant COLOUR_SET		"#00F#0F0#F00#0FF#FF0#F80#888#F0F#800#880#088#A33#8F0#FCD"					// Colours buttons/arrows can use

#constant MAX_LYRIC_FONTSIZE (64)

// ****************************************************************************************************************************************************************
//																	Scan Codes
// ****************************************************************************************************************************************************************

#constant KEY_ENTER		   13
#constant KEY_PAGEUP       33
#constant KEY_PAGEDOWN     34
#constant KEY_END          35
#constant KEY_HOME         36
#constant KEY_UP           38
#constant KEY_DOWN         40
#constant KEY_SPACE 	   32

// ****************************************************************************************************************************************************************
//													Constant values that aren't actual constants
// ****************************************************************************************************************************************************************

type Constants																							// Control constants
	screenWidth,screenHeight as integer																	// Screen size
	musicOn,metronomeOn,isRunning as integer 															// Controls
	fretY,fretHeight as integer 																		// Fretboard position/size
	barX,barWidth as integer 																			// Bar origin and width
	sineY,sineHeight as integer 																		// Curve position
	trackerY,trackerMargin as integer 																	// Tracker position
	tempoPercent as integer 																			// Tempo adjustments %
	flipFretboard as integer 																			// Flip Fretboard ?
endtype

global debug$ as string = ""																			// String containing debug information
global ctl as Constants

// ****************************************************************************************************************************************************************
//																Print Debug Information
// ****************************************************************************************************************************************************************

function ShowDebug()
	for l = 1 to CountStringTokens(debug$,"&")
		print("DBG:{"+GetStringToken(debug$,"&",l)+"}")
	next l
endfunction

// ****************************************************************************************************************************************************************
//																	Assert/Error
// ****************************************************************************************************************************************************************

function ERROR(msg$ as String)
	while GetRawKeyState(27) = 0 																	// Display until escaped.
		print(msg$)
		Sync()
	endwhile
	End
endfunction

function ASSERT(assert as integer,msg$ as String)
	if assert = 0 then ERROR("Assert Failed : "+msg$)
endfunction

// ****************************************************************************************************************************************************************
//																	Structures
// ****************************************************************************************************************************************************************

type NoteEvent
	time as integer																					// Event time in millibars (1000 millibars in each bar)
	name$ as string																					// Name of chord to be displayed or empty string if none.
	fret as integer[4]																				// Chromatic fret position of note, 99 if not played.
	isUpStroke as integer 																			// Non zero if upstroke
endtype

type ChordEvent
	time as integer																					// Event time in millibars (1000 millibars in each bar)
	name$ as string																					// Name of new chord
	fret as integer[4]																				// Chromatic fre position of note, 99 if not played.
endtype

type Bar
	barNumber as integer																			// Number of this bar
	noteCount as integer																			// Number of note events in this bar
	notes as NoteEvent[6]																			// Actual note events
	lyric$ as string																				// Lyrics in this bar, if any (empty string is no lyrics)
	baseID as integer																				// Base ID for this bar (may use baseID to baseID + 999)
	isDrawn as integer 																				// Non zero if this bar is drawn on the display
	isStrummed as integer 																			// Non zero if this bar is strummed.
	xPosition as integer 																			// Where it was drawn (if drawn)
endtype

type Song
	tempo as integer																				// default tempo 
	beats as integer																				// default beats per bar 
	strings as integer 																				// Device strings
	syncopation as integer																			// syncopation
	name$ as string																					// Name of song
	author$ as string																				// Song writer(s)
	translator$	as string																			// Translator
	barCount as integer																				// Number of bars
	bars as Bar[8]																					// Bars in the song
	chordCount as integer																			// Number of chord events
	chordEvents as ChordEvent[1]																	// Chord events, one exists for each chord entry change
	lyricSize# as float																				// Size of lyric font.
endtype

type ChordView
	x,y as integer																					// Position
	width,height as integer																			// Size
	id as integer 																					// base ID
	label as string 																				// Label (now/next)
endtype

// ****************************************************************************************************************************************************************
//																	Set up Common things and screen
// ****************************************************************************************************************************************************************

function COMSetup()
	ctl.screenWidth = 1024																			// Screen size
	ctl.screenHeight = 768
	ctl.barX = 140
	ctl.barWidth = 530
	ctl.fretY = 280																					// Fretboard position
	ctl.fretHeight = 380
	ctl.sineY = ctl.fretY+ctl.fretHeight*37/100														// Sine position
	ctl.sineHeight = ctl.fretHeight * 24 / 100
	y = ctl.fretY+ctl.fretHeight + MAX_LYRIC_FONTSIZE
	ctl.trackerY = (y + ctl.screenHeight)/2															// Tracker position
	ctl.trackerMargin = ctl.screenWidth / 32 
	ctl.musicOn = 1																					// Controls
	ctl.metronomeOn = 1
	ctl.isRunning = 1
	ctl.tempoPercent = 100 
	
	OpenToRead(1,"flipfretboard.txt")																// Check if flipped.
	a$ = ReadLine(1)
	CloseFile(1)	
	ctl.flipFretboard = asc(lower(a$)) = asc("y")
	
	SetWindowTitle("Mandolin Trainer : build "+str(BUILD_NUMBER)+" ("+BUILD_DATE+")")				// Screen set up
	LoadImages()																					// Load in all used images
	SetWindowSize(ctl.screenWidth,ctl.screenHeight,0)
	SetVirtualResolution(ctl.screenWidth,ctl.screenHeight)
	SetOrientationAllowed(0,0,1,1)
	SetErrorMode(2)
	SetPrintColor(0,0,0)
	SetPrintSize(24.0)
	img = CreateSprite(LoadImage(GFXDIR+"background.png"))											// Background image
	SetSpriteSize(img,ctl.screenWidth,ctl.screenHeight)
	SetSpriteDepth(img,99)
endfunction

function LoadImages()
	LoadImage(IMG_FRAME,GFXDIR+"selector.png")														// Load Images
	LoadImage(IMG_HANDLE,GFXDIR+"sphere_orange.png")
	LoadImage(IMG_FRETBOARD,GFXDIR+"fretboard.png")														
	LoadImage(IMG_NOTEBOX,GFXDIR+"notebutton.png")
	LoadImage(IMG_STRING,GFXDIR+"string.png")
	LoadImage(IMG_BAR,GFXDIR+"bar.png")
	LoadImage(IMG_REDSPHERE,GFXDIR+"sphere_red.png")													
	LoadImage(IMG_GREENSPHERE,GFXDIR+"sphere_green.png")											
	LoadImage(IMG_YELLOWSPHERE,GFXDIR+"sphere_yellow.png")											
	LoadImage(IMG_SINECURVE,GFXDIR+"sinecurve.png")
	LoadImage(IMG_SINECURVE_WIDE,GFXDIR+"sinecurve_wide.png")
	LoadImage(IMG_RECTANGLE,GFXDIR+"rectangle.png")
	LoadImage(IMG_METRONOME,GFXDIR+"metronome.png")
	LoadImage(IMG_ICONBOX,GFXDIR+"icon_frame.png")
	LoadImage(IMG_ARROW,GFXDIR+"arrow.png")
	LoadImage(IMG_MSTRING,GFXDIR+"mstring.png")
	SetTextDefaultFontImage(LoadImage(GFXDIR+"font.png"))											// Standard Font
endfunction
