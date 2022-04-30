
/******************************************************
* Description: 
* 			   
* 
* Author: Iakov Umrikhin
* Date created: 06.04.2022
*******************************************************/

// Part 5: Emergency button

// initialise START bit
start_bit := START;
stop_bit := STOP;
emergency := PBE5;

// initiallise timer
floorServiceTimer.PRE := 3000;
floorServiceTimer.ACC := 0;

(***********************
 * NOTES 
 * outPbFloor : 11 -> FPB1R
 				 8 -> FPB4	
   inPbFloor: 	3 -> PB1
   		b		0 -> PB4
	*)
 
IF S:FS THEN
    
	JSR(burnData);

END_IF;

// change an intermediate state
IF currentState <> nextState THEN
    currentState := nextState;
END_IF;


// main states
// state 0: launch the system:

IF (currentState = 0 AND nextState = 0) THEN

	IF start_bit THEN
		nextState := 1;	
	END_IF;

END_IF;

						// state 1

IF (currentState = 1 AND nextState = 1) THEN
	
  	IF floorSenseRef.0 THEN

		// move to a next state
	    nextState := 2;	  
    END_IF;

	outFloorBits.11 := 1;

	// turn the motor on

	// to make sure that the lyft doesn't burst through the roof
	// reverse its motion

END_IF;

// transition from State 1 to 2
IF (currentState = 1 AND nextState = 2) THEN

	IF firstFloorBit = 1 THEN
		outFloorBits := 0;
		firstFloorBit := 0;
	END_IF;

	IF floorArray[currFloorCntr] = 0  OR nextFloorCntr = -1 THEN
		
		JSR(clearArray); // subroutine
		outFloorBits := 0;
		inFloorBits := 0;

		JSR(countFloors);
	END_IF;
	
	zeroFloorCntr := 0;

END_IF;

						// state 2: wait for a call

IF (currentState = 2 AND nextState = 2) THEN

	// move to a next state
	IF floorServiceTimer.DN THEN
		
		IF (serviceDoorBool = 1) THEN

			nextState := 4;

		ELSE 

			nextState := 3;

		END_IF;

	END_IF;

	// increase the currFloorCntr only if there is a floor 
	// to move to
	floorServiceTimer.Reset := 0;
	// maybe you could remove bits.[N] from the IF 
	// statement. Should it work, then the code looks simpler
	// check if the outside panel button is pressed

	outPbBool [:=] outPbFloor.11 OR outPbFloor.10 OR outPbFloor.9 OR outPbFloor.8;
	inPbBool [:=] inPbFloor.3 OR inPbFloor.2 OR inPbFloor.1 OR inPbFloor.0;

	floorNumOut := bits AND outPbFloor; 
	floorNumIn := bits AND inPbFloor;

	IF outPbBool AND NOT one_shot_out THEN
		// enable the floorServiceTimer

		floorNumOut := 2048 / floorNumOut;

		CASE floorNumOut OF
			1: 
				floorNumOut := 1;
			2:
				floorNumOut := 2;
			4:
				floorNumOut := 3;
			8:
				floorNumOut := 4;
		END_CASE;
		
		outPbCntr := 12 - floorNumOut;

		outFloorBits.[outPbCntr] := 1;
		floorArray[nextFloorCntr] := floorNumOut;

		// reset the floorServiceTimer
		floorServiceTimer.Reset := 1;

		nextFloorCntr := nextFloorCntr + 1;
		buttonPressDetection := 1;
	END_IF;

	one_shot_out := outPbBool;


	// check if the inside panel button is pressed
	IF inPbBool AND NOT one_shot_in THEN

		floorNumIn := 8 / floorNumIn;

		CASE floorNumIn OF
			1: 
				floorNumIn := 1;
			2:
				floorNumIn := 2;
			4:
				floorNumIn := 3;
			8:
				floorNumIn := 4;
		END_CASE;

		inPbCntr := 4 - floorNumIn;

		inFloorBits.[inPbCntr] := 1;
		floorArray[nextFloorCntr] := floorNumIn;

		// reset the floorServiceTimer
		floorServiceTimer.Reset := 1;

		nextFloorCntr := nextFloorCntr + 1;
		buttonPressDetection := 1;
	END_IF;

	one_shot_in := inPbBool;

	IF nextFloorCntr > 4 THEN
		
		nextFloorCntr := 0;
		JSR(clearArray);

		outFloorBits := 0;
		inFloorBits := 0;
	END_IF;

	IF floorArray[currFloorCntr] >= 1 AND NOT floorServiceTimer_one_shot THEN
		floorServiceTimer.TimerEnable := 1;	
	END_IF;

	TONR(floorServiceTimer);

	floorServiceTimer_one_shot [:=] floorServiceTimer.EN;

END_IF;

// transition from State 2 to 4
IF (currentState = 2 AND nextState = 4) THEN
		floorServiceTimer.DN := 0;
		floorServiceTimer.Reset := 1;
		floorServiceTimer.TimerEnable := 0;
		serviceDoorBool := 0;
END_IF;

// transition from State 2 to 3; sort the list of floors
IF (currentState = 2 AND nextState = 3) THEN

	// desable the floorServiceTimer
	// reset the floorServiceTimer
	floorServiceTimer.DN := 0;
	floorServiceTimer.Reset := 1;
	floorServiceTimer.TimerEnable := 0;


	JSR(countFloors);
	
(*			MULTIPLE-CALLS ALGORITHMS. Start			*)

	IF currentFloor = 1 THEN
		JSR(lowSort);
		JSR(maxElement);
	END_IF;

	IF currentFloor = 4 THEN
		maxElementValue := 0;
		JSR(highSort);
		JSR(minElement);
		prevFloor := 4;
	END_IF;		

//	IF currentFloor = 3 AND prevFloor = 4 THEN
	IF prevFloor = 4 THEN

		JSR(downDirectionSort);

		// floor swap
		IF floorArray[currFloorCntr] = 4 THEN
			tempFloor := floorArray[currFloorCntr];
			JSR(elementShiftLeft);
			floorArray[nextFloorCntr-1] := tempFloor;
		END_IF;
		// end
		prevFloor := 0;
	END_IF;

	IF (maxElementValue = currentFloor) AND (currentFloor <> 4) THEN

		JSR(maxElement);

		IF maxElementValue > currentFloor THEN
			JSR(highSort);
		ELSE 
			maxElementValue := 0;
			JSR(highSort);
			JSR(minElement);
		END_IF;

	END_IF;

	IF (minElementValue = currentFloor) THEN

		minElementValue := 0;
		JSR(lowSort);
		JSR(maxElement);

	END_IF;

(*			MULTIPLE-CALLS ALGORITHMS. End			*)


	// floor repeats or it is zero; shift by one to the left
	// if there are more than 4 zeros in the array then the array is empty
	WHILE (floorArray[currFloorCntr] = floorArray[currFloorCntr + 1] OR floorArray[currFloorCntr] = 0) AND (zeroFloorCntr <> 4) DO

		IF (floorArray[currFloorCntr] = 0) THEN
			zeroFloorCntr := zeroFloorCntr + 1;
		END_IF;

		JSR(elementShiftLeft);

	END_WHILE;

	// check if the array's element is zero
	// act accordingly 
	IF floorArray[currFloorCntr] = 0 THEN

		JSR(elementShiftLeft);

	END_IF;

	// calculate which floor's sensor to stop at
	floorSenseCntr := floorArray[currFloorCntr] - 1;

	JSR(countFloors);
END_IF;

						// state 3: move to a floor

IF (currentState = 3 AND nextState = 3) THEN

	// check if the called floor's sensor is on
	IF floorSenseRef.[floorSenseCntr] THEN

		nextState := 4;

	END_IF;


	// turn the motor on

	(* if the next floor is lower than the current floor
	   then reverse the direction of the lyft *)

END_IF;

// transition from state 3 to state 4; 
IF (currentState = 3 AND nextState = 4) THEN

	currentFloor := floorArray[currFloorCntr];
	
	outFloorBits.[12 - currentFloor] := 0;
	inFloorBits.[4 - currentFloor] := 0;
	
	serviceDoorBool := 1;

END_IF;
						// state 4: stop the motion; return to State 2

IF (currentState = 4 AND nextState = 4) THEN

	IF (serviceDoorBool = 1) THEN
		nextState := 2;	// wait for 3 seconds to service a floor
	END_IF;

	IF (serviceDoorBool <> 1) THEN
		JSR(timerService);
	END_IF;

	outPbBool [:=] outPbFloor.11 OR outPbFloor.10 OR outPbFloor.9 OR outPbFloor.8;
	inPbBool [:=] inPbFloor.3 OR inPbFloor.2 OR inPbFloor.1 OR inPbFloor.0;

	floorNumOut := bits AND outPbFloor;
	floorNumIn := bits AND inPbFloor;

	IF outPbBool AND NOT one_shot_out THEN
		// enable the floorServiceTimer

		floorNumOut := 2048 / floorNumOut;

		CASE floorNumOut OF
			1: 
				floorNumOut := 1;
			2:
				floorNumOut := 2;
			4:
				floorNumOut := 3;
			8:
				floorNumOut := 4;
		END_CASE;
		
		outPbCntr := 12 - floorNumOut;

		outFloorBits.[outPbCntr] := 1;
		floorArray[nextFloorCntr] := floorNumOut;

		// reset the floorServiceTimer
		floorServiceTimer.Reset := 1;

		nextFloorCntr := nextFloorCntr + 1;
		buttonPressDetection := 1;
	END_IF;

	one_shot_out := outPbBool;


	// check if the inside panel button is pressed
	IF inPbBool AND NOT one_shot_in THEN

		floorNumIn := 8 / floorNumIn;

		CASE floorNumIn OF
			1: 
				floorNumIn := 1;
			2:
				floorNumIn := 2;
			4:
				floorNumIn := 3;
			8:
				floorNumIn := 4;
		END_CASE;

		inPbCntr := 4 - floorNumIn;

		inFloorBits.[inPbCntr] := 1;
		floorArray[nextFloorCntr] := floorNumIn;

		// reset the floorServiceTimer
		floorServiceTimer.Reset := 1;

		nextFloorCntr := nextFloorCntr + 1;
		buttonPressDetection := 1;
	END_IF;

	one_shot_in := inPbBool;

	IF nextFloorCntr > 4 THEN
		
		nextFloorCntr := 0;
		JSR(clearArray);

		outFloorBits := 0;
		inFloorBits := 0;
	END_IF;

END_IF;

IF (currentState = 4 AND nextState = 2) THEN
	
	IF (serviceDoorBool <> 1) THEN
	 
		JSR(elementShiftLeft);

		JSR(countFloors);

		// floor repeats or it is zero; shift by one to the left
		// if there are more than 4 zeros in the array then the array is empty
		WHILE (floorArray[currFloorCntr] = floorArray[currFloorCntr + 1] OR floorArray[currFloorCntr] = 0) AND (zeroFloorCntr <> 4) DO

			IF (floorArray[currFloorCntr] = 0) THEN
				zeroFloorCntr := zeroFloorCntr + 1;
			END_IF;

			JSR(elementShiftLeft);

		END_WHILE;
	
		IF (buttonPressDetection <> 1) THEN
			floorArray[nextFloorCntr] := 0;
			nextFloorCntr := nextFloorCntr - 1;
			JSR(countFloors);
		END_IF;

		buttonPressDetection := 0;

	END_IF;
END_IF;
						// EMERGENCY STATE
IF emergency THEN
	nextState := 5;
END_IF;


IF (currentState = 5 AND nextState = 5) THEN

	emergencyLight := 64; // 5th bit
	
	// if one of the sensors is active
	// the lyft is on one of the floors
	IF (floorSenseRef.[floorSenseCntr]) THEN
		door_bool [:=] 1;
	END_IF;

	// if the emergency occurs between floors;
	// only possible, when neither of sensors is on

	IF start_bit THEN
		nextState := 0;
	END_IF;

END_IF;

// Transition from State 5 to 2; clear all data
IF (currentState = 5 AND nextState = 0) THEN

	JSR(burnData);

END_IF;

// if stop pressed clear everything and 
// return to state 1
IF NOT stop_bit THEN

	JSR(burnData);

END_IF;

						(* OUTPUT SECTION *)

// output for the outside panel lights
lightRef [:=] outFloorBits OR inFloorBits OR ilc_bit OR emergencyLight;

// elevator's door bit
SOL0 := door_bool;

// output for motor's bits
M0 [:=] (currentState = 1 AND nextState = 1) OR (currentState = 3 AND nextState = 3);
CR0 [:=] ((currentState = 1 AND nextState = 1) AND NOT floorSenseRef.0) OR ((currentState = 3 AND nextState = 3) AND (floorArray[currFloorCntr] < currentFloor));
