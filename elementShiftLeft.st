// elementsShiftLeft. START
// Description: shift elements of the array by one 
//				to the left
SBR();

	FOR shiftCount := 0 to 3 DO

		floorArray[shiftCount] := floorArray[shiftCount + 1];

	END_FOR;

	shiftCount := 0;
// elementsShiftLeft. END