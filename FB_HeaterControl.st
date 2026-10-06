FUNCTION_BLOCK FB_HeaterControl
VAR_IN_OUT
 stData:ST_Heater; //hem sıcaklığı okur hem de çıkışı aynı pakete yazar
END_VAR
VAR
	bInternalFault:BOOL; //arızayı hafızada tutmak için 
END_VAR


IF stData.rCurrentTemp>stData.rMaxTempLimit OR stData.bOverheatSwitch THEN 
	bInternalFault:=TRUE;	
END_IF
IF stData.bReset AND (stData.rCurrentTemp<= stData.rMaxTempLimit) AND NOT stData.bOverheatSwitch THEN
	bInternalFault:=FALSE;
END_IF
IF stData.bEnable=TRUE AND NOT bInternalFault THEN
	stData.bHeaterOut:=TRUE;
ELSE
    stData.bHeaterOut:=FALSE;	
END_IF
stData.bAlarm:=bInternalFault;
END_FUNCTION_BLOCK