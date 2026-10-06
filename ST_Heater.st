TYPE ST_Heater :
STRUCT
	
	bEnable:BOOL; //ısıtıcıyı çalıştır emri
	bReset:BOOL; //alarm sıfırlama
	rCurrentTemp:REAL; //sensörden okunan anlık sıcaklık
	rMaxTempLimit:REAL:=120.0;
	bOverheatSwitch:BOOL; //mekanik acil sıcaklık anahtarı/şalteri, true ise tehlike
	bHeaterOut:BOOL; //Rezistansı süren kontaktör
	bAlarm:BOOL; //Aşırı sıcaklık/güvenlik alarmı
END_STRUCT
END_TYPE
