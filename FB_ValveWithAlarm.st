FUNCTION_BLOCK FB_ValveWithAlarm
VAR_INPUT
	bOpenCmd:BOOL;  //Vanayı aç kapat emri
	bOpenedSensor:BOOL; //vana tamamen açık sensörü
	bClosedSensor:BOOL; //vana tamamen kapalı sensörü
	bReset:BOOL; //hata sıfırlama butonu 
	tTimeout:TIME:=T#5S; // max hareket süresi
END_VAR
VAR_OUTPUT
	bValveOpenOut:BOOL; //selenoid valfe giden bobin çıkışı
	bAlarm:BOOL; //genel vana hatası
END_VAR
VAR
	fbOpenTimer:TON; //açılma süresini sayan zamanlayıcı
	fbCloserTimer:TON; //kapanma süresini sayan zamanlayıcı
	bInternalFault:BOOL; //arıza hafızası
END_VAR

fbOpenTimer(IN:=(bValveOpenOut AND NOT bOpenedSensor),PT:=tTimeout);
fbCloserTimer(IN:=(NOT bValveOpenOut AND NOT bClosedSensor),PT:=tTimeout);
IF (fbOpenTimer.Q OR fbCloserTimer.Q) OR (bOpenedSensor AND bClosedSensor) THEN
    bInternalFault:=TRUE;   
ELSIF bReset THEN
	bInternalFault:=FALSE;
END_IF 
IF bOpenCmd AND NOT bInternalFault THEN
    bValveOpenOut:=TRUE;
ELSE 
    bValveOpenOut:=FALSE;
END_IF
bAlarm:=bInternalFault;	
END_FUNCTION_BLOCK