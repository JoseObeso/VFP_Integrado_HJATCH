PUBLIC gconecta

** Leer del INI
Archivo_ = FILE(".\bd.ini") 
IF Archivo_ = .T. 
   N_Cadena = ALLTRIM(FILETOSTR(".\bd.ini")) 
   x_Server = ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
   N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
   x_UID =    ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
   N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
   x_PWD =    ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
   N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
   x_Change = CHRTRAN(N_Cadena,CHR(13),"*") 
   x_DBaseName = Substr(x_Change,1,ATC("*",x_Change,1)-1) 
   lcStringCnxLocal = "Driver={SQL Server Native Client 10.0};" + ; 
          "SERVER=" + x_Server + ";" + ; 
          "UID=" + x_UID + ";" + ; 
          "PWD=" + x_PWD + ";" + ; 
          "DATABASE=" + x_DBaseName + ";"
  ?lcStringCnxLocal
  Sqlsetprop(0,"DispLogin" , 3 ) 
  gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
ENDIF
  
TEXT TO lbusca noshow
   SELECT [NOMBRES],[HABER],[GRABO]   FROM [BDPERSONAL].[dbo].[asueldos] ORDER BY NOMBRES
ENDTEXT
lejecutagrabar = sqlexec(gconecta,lbusca, "TNOM")

SELECT TNOM
GO top
SCAN
 lnombre = ALLTRIM(tnom.nombres)
 lmonto = tnom.HABER
 TEXT TO lgrabacadena noshow
      UPDATE [BDPERSONAL].[dbo].[MAESTRO] SET haber = ?lmonto WHERE NOMBRE = ?lnombre
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lgrabacadena) 
 IF lejecuta > 0
    TEXT TO lqry_ver noshow
       UPDATE [BDPERSONAL].[dbo].[asueldos] SET GRABO = '1' WHERE NOMBRES = ?lnombre
    ENDTEXT
    lejecuta=SQLEXEC(gconecta,lqry_ver)
   cMensage = ' GRABACION CORRECTA DE : ' + lnombre
 _Screen.Scalemode = 0
 Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait
 ELSE
    TEXT TO lqry_ver2 noshow
       UPDATE [BDPERSONAL].[dbo].[asueldos] SET GRABO = '0' WHERE NOMBRES = ?lnombre
    ENDTEXT
    lejecuta=SQLEXEC(gconecta,lqry_ver2)
   cMensage = ' ERROR DE GRABACION DE : ' + lnombre
   _Screen.Scalemode = 0
   Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait
 ENDIF
 
ENDSCAN


