

/******************************************************
* Description: This SBR is to delete all the data
* 			   at the begining of the lyft's operation
* 
* Author: Iakov Umrikhin
* Date created: 06.04.2022
*******************************************************/
SBR();

	currentState := 0;
	nextState := 0;

	floorSenseRef := 0;

	motor_bit := 0;
	reverse_bit := 0;

    currentFloor := 1;
	currFloorCntr := 0;

	nextFloor := 0;
	nextFloorCntr := 0;
	
	inFloorBits := 0;
	outFloorBits := 0;

	one_shot := 0;

	sorting := 0;
	sortingCntr := 0;

	emergencyLight := 0;
	door_bool := 0;

	floorServiceTimer.Reset := 1;
	
	serviceDoorBool := 0;

	JSR(clearArray);

	nextState := 0;

