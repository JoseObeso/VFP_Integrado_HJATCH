PUBLIC gconecta, lmesx, lanio
CLEAR
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
  Sqlsetprop(0,"DispLogin" , 3 ) 
  gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
ENDIF
?lcStringCnxLocal  
cMensage = " TRABAJANDO CON ITEMS DUPLICADO ............."
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait


TEXT TO lselecciona_items noshow
  select codcpt, ITEM, nombre  from item where substring(item,1,1) = '6' and activo = '1' order by ITEM asc
ENDTEXT
lejecutagrabar = sqlexec(gconecta,lselecciona_items, "tsele")
SELECT tsele
GO top
SCAN
   liditem = ALLTRIM(tsele.item)
   lcnombre = ALLTRIM(substr(tsele.nombre,1,100))
   TEXT TO lver_numero noshow
     select top 1 * from PRECIO where ITEM = ?liditem
   ENDTEXT
   lejecutagrabar = sqlexec(gconecta,lver_numero, "tnum")
   SELECT tnum
   lidrec = tnum.idrecord
   
   TEXT TO lelim noshow
      delete from PRECIO where ITEM = ?liditem and IDRECORD <> ?lidrec
   ENDTEXT
   lejecutagrabar = sqlexec(gconecta,lelim)
   
   cMensage = " TRABAJANDO PARA ITEM " +lcnombre
   _Screen.Scalemode = 0
   Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait
ENDSCAN


TEXT TO leliminar_final noshow
  DELETE FROM PRECIO WHERE IDRECORD IN (52290, 53290, 54290, 55290)
ENDTEXT
lejecutagrabar = sqlexec(gconecta,leliminar_final)




cMensage = " PROCESO TERMINADO "
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait


