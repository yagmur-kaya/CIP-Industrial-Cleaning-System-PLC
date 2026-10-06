FUNCTION_BLOCK FB_Motor_V2
VAR_IN_OUT
	stData:ST_MotorData;
END_VAR
VAR
	fbTimeoutTimer:TON;
	bInternalFault:BOOL;
END_VAR

fbTimeoutTimer(IN:=(stData.bMotorOut AND NOT stData.bRunningFeedBack),PT:=stData.tDelayTime);
IF stData.bTrip=TRUE OR  fbTimeoutTimer.Q THEN 
     bInternalFault:=TRUE;	
ELSIF stData.bReset=TRUE AND stData.bTrip=FALSE THEN
    bInternalFault:=FALSE;	
END_IF
IF stData.bStartCmd AND NOT bInternalFault THEN
	 stData.bMotorOut:=TRUE;
ELSE
     stData.bMotorOut:=FALSE;	
END_IF
stData.bAlarm:=bInternalFault;
END_FUNCTION_BLOCK