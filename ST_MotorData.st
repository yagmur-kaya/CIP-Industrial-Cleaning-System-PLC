TYPE ST_MotorData :
STRUCT
	bStartCmd:BOOL; //start emri
	bRunningFeedBack:BOOL; //Motordan gelen çalışıyorum sinyali
	bTrip:BOOL; //Termik/arıza rölesi kontağı TRUE ise acil arıza
	bReset:BOOL; //Arızayı silme butonu 
	tDelayTime:TIME;
	
	bMotorOut:BOOL; //Kontaktör çekme çıkışı
	bAlarm:BOOL; //Arıza lambası/alarm durumu	
END_STRUCT
END_TYPE