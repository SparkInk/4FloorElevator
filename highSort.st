
// highSort. START
SBR();
	
    FOR i:= 1 to 3 DO
		min := floorArray[i];
		j := i - 1;
        WHILE j >= 0 AND floorArray[j] < min DO
			floorArray[j + 1] := floorArray[j];
			j := j - 1;
		END_WHILE;
		floorArray[j + 1] := min;
	END_FOR;
	j := 0;
// highSort. END