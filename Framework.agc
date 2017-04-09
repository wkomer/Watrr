//Core Library
//Paul Birkholtz
//2016/07/04


//INITIAL SCREEN SETUP/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////INITALIZE SCREEN////
function InitializeScreen(h as integer, w as integer, r as integer, c as integer, t as string)
	SetErrorMode(2)
	if w= 0 or h= 0
		SetWindowSize(h,w,1)														//if width or hieght of window== 0 makes it fullscreen
	else														
		SetWindowSize(h,w,1)																//else set window hieght and width to w and h
		SetWindowTitle(t)																		//set title to T
	endif
	SetClearColor((c&&0xFF0000)>>16,(c&&0xFF00)>>8,c&&0xFF)									//sets window default color
	ClearScreen()
	UseNewDefaultFonts( 1 ) 																									// since version 2.0.20 we can use nicer default fonts																			
	SetOrientationAllowed(r,r,0,0)						//sets orientation permissions
	SetSyncRate(25, 0)
endfunction

////SHOW SPLASH////
function ShowSplashScreen(fileName as string)
	LoadImage(1,fileName)																	//loads splash screen with a ID of 1
	CreateSprite(1,1)																		//places splash screen on screen
	SetSpriteSize(1,100,100)																//makes sprite fill 100% of the screen
	Sync()
endfunction

////HIDE SPLASH////
function HideSplashScreen(s as integer)														
	ResetTimer()																			//sets program timer to 0
	while Timer()< s and GetPointerPressed()= 0												//checks for user click or time limit
		sync()
	endwhile
	DeleteSprite(1)																			//deletes splash sprite from memory
	DeleteImage(1)																			//deletes splash image from memory
	sync()
endfunction	

function ClearMem()																			//clears all resources from memory, an exit function
	DeleteAllImages()
	DeleteAllObjects()
	DeleteAllSprites()
	DeleteAllText()
endfunction
