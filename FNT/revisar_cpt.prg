** Revsiar cuentas al detalle de liquidaciones *
CLEAR
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
      lcStringCnxLocal = "Driver={SQL Server Native Client 10.0};" +  "SERVER=" + x_Server + ";" +  "UID=" + x_UID + ";" + "PWD=" + x_PWD + ";" + "DATABASE=" + x_DBaseName + ";"
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF
?lcStringCnxLocal
cMensage = '...BUSCANDO.......' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

 

TEXT TO lvercpt noshow
    select CODCPT, SECCION, SUBSECCION from ITEM where SUBSTRING(ITEM,1,1) = '5' and ABREVIATURA is null 
ENDTEXT
lejecutabusca = sqlexec(gconecta,lvercpt,"tcpt")
SELECT tcpt
GO top
SCAN
  lcpt = ALLTRIM(tcpt.codcpt)
  lcseccion = ALLTRIM(tcpt.seccion)
  lcsubseccion = ALLTRIM(tcpt.subseccion)
  TEXT TO lver_update noshow
     update ITEM set SECCION = ?lcseccion, SUBSECCION = ?lcsubseccion where codcpt = ?lcpt AND ACTIVO = 7
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lver_update)
  WAIT windows "Actualizando CPT :  " +lcpt nowait
ENDSCAN
  cMensage = '...FIN DE ACTUALIZACION CPT....'
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

