

SBR();

	FOR numFloorsCntr := 0 to 3 DO
		
		IF tempArray[numFloorsCntr] > 0 THEN
			numFloors := numFloors + 1;
		END_IF;

	END_FOR;

	numTempFloors := numFloors;

	numFloors := 0;