//Güvenlik ve Genel Arıza Kontrolü
bGenelAriza:=fbSuVanasi.bAlarm 
OR fbKostikVanasi.bAlarm 
OR fbAsitVanasi.bAlarm 
OR fbTahliyeVanasi.bAlarm 
OR stPompa.bTrip OR 
stIsitici.bOverheatSwitch 
OR bAcilStop;
//Sistem bekleme veya zaten hata durumunda değilse ve arıza gelirse doğrudan kilitlen
IF bGenelAriza THEN
	eAktifAdim:=Enum_CIP.HATA;
END_IF
ToplamSureTimer(IN:= (eAktifAdim <> Enum_CIP.BEKLEME)
 AND (eAktifAdim <> Enum_CIP.HATA)
 AND (NOT bReset),
 PT:=T#2M);

IF bStop OR bReset THEN
	eAktifAdim:=Enum_CIP.BEKLEME;
	bAdimTimerAktif:=FALSE;
	bStart:=FALSE;
	
	fbSuVanasi.bOpenCmd:=FALSE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=FALSE;
	
	stPompa.bStartCmd:=FALSE;
	stIsitici.bEnable:=FALSE;
END_IF

//ADIMLAR
CASE eAktifAdim OF	
	Enum_CIP.BEKLEME:
	bAdimTimerAktif:=FALSE;
	IF bStart AND (NOT bHafizaDolu) THEN
		bStart:=FALSE;
		eAktifAdim:=Enum_CIP.ON_CALKALAMA;		
	END_IF
	ENUM_CIP.ON_CALKALAMA:
	fbSuVanasi.bOpenCmd:=TRUE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=TRUE;
	
	stPompa.bStartCmd:=TRUE;
	stIsitici.bEnable:=FALSE;
	
	tAdimSuresi:=T#10S;
	bAdimTimerAktif:=TRUE;
	IF sure.Q THEN
		bAdimTimerAktif:=FALSE;
		eAktifAdim:=Enum_CIP.KOSTIK_YIKAMA;
	END_IF
	ENUM_CIP.KOSTIK_YIKAMA:
	fbSuVanasi.bOpenCmd:=FALSE;
	fbKostikVanasi.bOpenCmd:=TRUE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=FALSE;
	
	stPompa.bStartCmd:=TRUE;
	stIsitici.bEnable:=TRUE;
	
	tAdimSuresi:=T#15S;
	IF rAnlikSicaklik>=65 THEN
		bAdimTimerAktif:=TRUE;
	ELSE
        bAdimTimerAktif:=FALSE;
	END_IF
	IF sure.Q THEN
		bAdimTimerAktif:=FALSE;
		eAktifAdim:=Enum_CIP.ARA_DURULAMA;
	END_IF	
	ENUM_CIP.ARA_DURULAMA:
	fbSuVanasi.bOpenCmd:=TRUE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=TRUE;
	
	stPompa.bStartCmd:=TRUE;
	stIsitici.bEnable:=FALSE;
	
	tAdimSuresi:=T#8S;
	bAdimTimerAktif:=TRUE;
	IF sure.Q THEN
		bAdimTimerAktif:=FALSE;
		eAktifAdim:=Enum_CIP.ASIT_YIKAMA;
	END_IF
	
    ENUM_CIP.ASIT_YIKAMA:
	fbSuVanasi.bOpenCmd:=FALSE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=TRUE;
	fbTahliyeVanasi.bOpenCmd:=FALSE;
	
	stPompa.bStartCmd:=TRUE;
	stIsitici.bEnable:=FALSE;
	
	tAdimSuresi:=T#12S;
	bAdimTimerAktif:=TRUE;
	IF sure.Q THEN
		bAdimTimerAktif:=FALSE;
		eAktifAdim:=Enum_CIP.SON_DURULAMA;	
	END_IF	
	ENUM_CIP.SON_DURULAMA:
	fbSuVanasi.bOpenCmd:=TRUE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=TRUE;
	
	stPompa.bStartCmd:=TRUE;
	stIsitici.bEnable:=FALSE;
	
	tAdimSuresi:=T#10S;
	bAdimTimerAktif:=TRUE;
	IF sure.Q THEN
		bAdimTimerAktif:=FALSE;
		eAktifAdim:=Enum_CIP.TAMAMLANDI;
	END_IF
	
    ENUM_CIP.TAMAMLANDI:
	fbSuVanasi.bOpenCmd:=FALSE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=FALSE;
	
	stPompa.bStartCmd:=FALSE;
	stIsitici.bEnable:=FALSE;
	
//PARTİ LOG KAYITLARI
	IF NOT PartiKaydedildi THEN
	 IF LogIndex<=5 THEN 
	  ToplamPartiSuresi:=ToplamSureTimer.ET;
	  CIPSayac:=CIPSayac+1;
	  SonPartiSureleri[LogIndex]:=ToplamPartiSuresi;
	  LogIndex:=LogIndex+1;
	  IF LogIndex>5 THEN
	  bHafizaDolu:=TRUE;
	  END_IF
	ELSE
     bHafizaDolu:=TRUE;   	
	END_IF
	PartiKaydedildi:=TRUE;
	END_IF
	
	fbTamamlandiTimer(IN:=TRUE,PT:=T#5S);
	IF fbTamamlandiTimer.Q OR bReset THEN
		fbTamamlandiTimer(IN:=FALSE,PT:=T#5S);
		PartiKaydedildi:=FALSE;
		rAnlikSicaklik:=20.00;
		eAktifAdim:=Enum_CIP.BEKLEME;
	END_IF

	ENUM_CIP.HATA:
	fbSuVanasi.bOpenCmd:=FALSE;
	fbKostikVanasi.bOpenCmd:=FALSE;
	fbAsitVanasi.bOpenCmd:=FALSE;
	fbTahliyeVanasi.bOpenCmd:=FALSE;
	
	stPompa.bStartCmd:=FALSE;
	stIsitici.bEnable:=FALSE;
	
	bAdimTimerAktif:=FALSE;
	IF NOT bGenelAriza AND bReset THEN
		eAktifAdim:=Enum_CIP.BEKLEME;
	END_IF
END_CASE
PartiSure1:=SonPartiSureleri[1];
	PartiSure2:=SonPartiSureleri[2];
	PartiSure3:=SonPartiSureleri[3];
	PartiSure4:=SonPartiSureleri[4];
	PartiSure5:=SonPartiSureleri[5]; 
IF bReset THEN
	bHafizaDolu:=FALSE;
	LogIndex:=1;
    FOR I:=1 TO 5 DO 
    SonPartiSureleri[I]:=T#0S;  
    END_FOR
CIPSayac:=0;
END_IF
sure(IN:=bAdimTimerAktif,PT:=tAdimSuresi);
//Fiziksel vana olmadığı için simülasyonda arızaya düşmesinler diye vanaların açık ve kapalı
//sensörlerini komutlara göre otomatik taklit ediyorum
fbSuVanasi.bOpenedSensor:=fbSuVanasi.bOpenCmd;
fbSuVanasi.bClosedSensor:= NOT fbSuVanasi.bOpenCmd;

fbKostikVanasi.bOpenedSensor:=fbKostikVanasi.bOpenCmd;
fbKostikVanasi.bClosedSensor:=NOT fbKostikVanasi.bOpenCmd;

fbAsitVanasi.bOpenedSensor:=fbAsitVanasi.bOpenCmd;
fbAsitVanasi.bClosedSensor:=NOT fbAsitVanasi.bOpenCmd;

fbTahliyeVanasi.bOpenedSensor:=fbTahliyeVanasi.bOpenCmd;
fbTahliyeVanasi.bClosedSensor:= NOT fbTahliyeVanasi.bOpenCmd;

//BLOK ÇAĞRILARI
fbSuVanasi();
fbKostikVanasi();
fbAsitVanasi();
fbTahliyeVanasi();
fbSirkulasyonPompa(stData:=stPompa);
fbIsitici(stData:=stIsitici);

//TANK SEVİYE VE SICAKLIK SİMÜLASYONU
CASE CIPSayac OF
	0:IsinmaHizi:=0.07;rHedefSicaklik:=68;
	1:IsinmaHizi:=0.12;rHedefSicaklik:=75;
	2:IsinmaHizi:=0.09;rHedefSicaklik:=66;
	3:IsinmaHizi:=0.14;rHedefSicaklik:=72;
	4:IsinmaHizi:=0.08;rHedefSicaklik:=80;
ELSE
     IsinmaHizi:=0.10;rHedefSicaklik:=68;	
END_CASE

IF eAktifAdim=Enum_CIP.KOSTIK_YIKAMA THEN 
	IF rAnlikSicaklik<65.0 THEN 
		rAnlikSicaklik:=rAnlikSicaklik+IsinmaHizi;
	END_IF
ELSIF eAktifAdim=Enum_CIP.TAMAMLANDI OR eAktifAdim=Enum_CIP.BEKLEME THEN
 IF rAnlikSicaklik>20.0 THEN
	rAnlikSicaklik:=rAnlikSicaklik-SogumaHizi; 
END_IF
END_IF	
CASE eAktifAdim OF
	Enum_CIP.ON_CALKALAMA: rHedefSeviye:=40.0;
    Enum_CIP.KOSTIK_YIKAMA: rHedefSeviye:=80.0;
	Enum_CIP.ARA_DURULAMA: rHedefSeviye:=50.0;
	Enum_CIP.ASIT_YIKAMA: rHedefSeviye:=75.0;
	Enum_CIP.SON_DURULAMA: rHedefSeviye:=60.0;
	Enum_CIP.TAMAMLANDI: rHedefSeviye:=00.0;
	Enum_CIP.BEKLEME: rHedefSeviye:=rSuSeviyesi;
	Enum_CIP.HATA: rHedefSeviye:=rSuSeviyesi;
ELSE
   rHedefSeviye:=0.00;	
 END_CASE  
IF rSuseviyesi<rHedefSeviye THEN
 rSuSeviyesi:=rSuSeviyesi+0.4;
  IF rsuSeviyesi>rHedefSeviye THEN
  rSuSeviyesi:=rHedefSeviye;
  END_IF
ELSIF rSuseviyesi>rHedefSeviye THEN
 rSuSeviyesi:=rSuSeviyesi-0.5;
 IF rsuSeviyesi<rHedefSeviye THEN
  rSuSeviyesi:=rHedefSeviye;
  END_IF
END_IF	
