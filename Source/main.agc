// Project: Golden Shower
// Made By: Paul Birkholtz
// Works with: Golden Shower Hardware

#include "Framework.agc"

//Initializes App Window and Settings
InitializeScreen(GetDeviceWidth(),GetDeviceHeight(),1,0,"Golden Shower")

//Initializes app ariables
global actTemp as integer= 0
global reqTemp as integer= 80
global waterSaved as float= 0.00
global waterUsed as float= 0.00

global sactTemp as string= " "
global sreqTemp as string= " "
global swaterSaved as string= " "
global swaterUsed as string= " "

LoadImage(1, "Background.png")
CreateSprite(1, 1)
SetSpriteSize(1,100,100)
SetSpriteSize(1,100,100)
SetSpritePosition(1,0,0)
Sync()
//HTTP Handler Function
function fetchData()
	http = CreateHTTPConnection()
	SetHTTPHost( http, "aws.fanara.me", 0 )

	// if the server takes a long time to respond this could make the app unresponsive
	global response as string= " "
	instruct as string= " "
	instruct = "aws.fanara/api/set_temp/" + str(reqTemp)
	response = SendHTTPRequest( http, "api/data" )
	SendHTTPRequest(http, instruct)

	CloseHTTPConnection(http)
	DeleteHTTPConnection(http)
	
	actTemp= Val(GetStringToken(response, ";", 1))
	waterUsed= ValFloat(GetStringToken(response, ";", 2))
	waterSaved= ValFloat(GetStringToken(response, ";", 3))
endfunction

//Creates App Dialogs
CreateText(1, sreqTemp)
SetTextSize(1,5)
SetTextPosition(1,0,10)

CreateText(2, sactTemp)
SetTextSize(2,5)
SetTextPosition(2,0,5)

CreateText(3, swaterSaved)
SetTextSize(3,5)
SetTextPosition(3,0,15)

CreateText(4, swaterUsed)
SetTextSize(4,5)
SetTextPosition(4,0,20)

CreateText(5, "Desired Temp Control")
SetTextSize(5,5)
SetTextPosition(5,14,55)

//Creates App User Controls
AddVirtualButton(1, 15, 94, 18)
SetVirtualButtonText(1, "Sync")
AddVirtualButton(2, 85, 94, 18)
SetVirtualButtonText(2, "Exit")

AddVirtualButton(6, 20, 75, 18)
SetVirtualButtonText(6, "-10 F")

AddVirtualButton(5, 40, 75, 18)
SetVirtualButtonText(5, "-1 F")

AddVirtualButton(4, 60, 75, 18)
SetVirtualButtonText(4, "+1 F")

AddVirtualButton(3, 80, 75, 18)
SetVirtualButtonText(3, "+10 F")


//MAIN LOOP
do
	Print(response)
	//Assigns string Variables Updated Values
	sactTemp= "Current Temperature: " + str(actTemp) + (" F")
	sreqTemp= "Desired Temperature: " + str(reqTemp) + (" F")
	swaterSaved= "Water Saved: " + str(waterSaved) + (" Gal")
	swaterUsed= "Water Used: " + str(waterUsed) + (" Gal")
	
	//Displays String Values in App
	SetTextString(1, sreqTemp)
	SetTextString(2, sactTemp)
	SetTextString(3, swaterSaved)
	SetTextString(4, swaterUsed)
	
	//Button Logic and checks 
	if GetVirtualButtonReleased(5)= 1
		if reqTemp<= 50
			print("Error Temp is too low!")
		else
			reqTemp= reqTemp - 1
		endif
	endif
	
	if GetVirtualButtonReleased(4)= 1
		if reqTemp>= 120
			print("Error Temp is too High!")
		else
			reqTemp= reqTemp + 1
		endif
	endif
	
	if GetVirtualButtonReleased(3)= 1
		if reqTemp>= 110
			print("Error Temp is too High!")
		else
			reqTemp= reqTemp + 10
		endif
	endif
	
	if GetVirtualButtonReleased(6)= 1
		if reqTemp<= 60
			print("Error Temp is too low!")
		else
			reqTemp= reqTemp - 10
		endif
	endif
	
	if actTemp>= reqTemp- 5 AND actTemp<= reqTemp+5
		SetTextColor(2,50,205,50,255)
	else
		SetTextColor(2,255,255,255,255)
	endif
	if waterSaved= 1
		SetTextColor(3,50,205,50,255)
	else
		SetTextColor(3,255,255,255,255)
	endif
	//Syncs Data with Hardware
	if 	 GetVirtualButtonReleased(1)= 1
		fetchData()
	endif
	
	if GetVirtualButtonReleased(2)= 1
		fetchData()
	endif
	
	//Exit Application
	if GetVirtualButtonReleased(2)= 1
		Exit
	endif
	
	Sync()
loop
