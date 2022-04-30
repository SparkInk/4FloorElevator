SBR();

	maxElementValue := 1;

	FOR maxElementCntr := 0 TO 3 DO

		IF (floorArray[maxElementCntr] > maxElementValue AND floorArray[maxElementCntr] <> 0) THEN
			maxElementValue := floorArray[maxElementCntr];
		END_IF;

	END_FOR;