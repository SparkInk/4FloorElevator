

SBR();

	FOR numFloorsCntr := 0 to 3 DO
		
		IF floorArray[numFloorsCntr] > 0 THEN
			numFloors := numFloors + 1;
		END_IF;

	END_FOR;

	nextFloorCntr := numFloors;

	numFloors := 0;