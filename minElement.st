SBR();

	minElementValue := 4;

	FOR minElementCntr := 0 TO 3 DO

		IF (floorArray[minElementCntr] < minElementValue AND floorArray[minElementCntr] <> 0) THEN
			minElementValue := floorArray[minElementCntr];
		END_IF;

	END_FOR;