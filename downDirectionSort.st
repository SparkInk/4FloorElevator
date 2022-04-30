SBR();


	JSR(highSort);
	JSR(countFloors);

	FOR i := 0 to (nextFloorCntr - 1) DO
		IF floorArray[i] > currentFloor THEN
			tempArray[i] := floorArray[0];
			JSR(elementShiftLeft);
			floorArray[nextFloorCntr - i - 1] := 0;
		END_IF;
	END_FOR;

	JSR(countFloorsTemp);
	JSR(countFloors);
	
	FOR j := 0 TO (numTempFloors - 1) DO
		floorArray[j + nextFloorCntr] := tempArray[j];
	END_FOR;