** GENERACION DE TARIFARIO MAYO 2017 - A PARTIR DEL SISTEMA *


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
      ?lcStringCnxLocal
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF

cMensage = '...GENERANDO LOS MAESTROS DE ITEMS .......' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

TEXT TO lqry_obtener_items noshow
  SELECT nro, item, codcpt, nombre  FROM [SIGSALUD].[dbo].[TARIFARIO_MAYO_2017] ORDER BY ITEM ASC
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_obtener_items, "t_items")  

SELECT t_items
GO top
SCAN
  lnnro = t_items.nro
  lcitem = ALLTRIM(t_items.item)
  lccodcpt = ALLTRIM(t_items.codcpt)
  
  TEXT TO lqry_obtener_precio_pagante noshow
     use sigsalud
     select precioa from precio where item = ?lcitem
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqry_obtener_precio_pagante, "tprecioa")  
  SELECT tprecioa
  lnprecioa=tprecioa.precioa
  
  TEXT TO lqry_sis noshow
     select precioe, precioh from precio where item = (select ITEM from ITEM where CODCPT = ?lccodcpt and ACTIVO = '7')  
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqry_sis, "tprecioss")  
  SELECT tprecioss
  lnpreciosis = tprecioss.precioe
  lnpreciosoat = tprecioss.precioh
  
  TEXT TO lqty_graba_precio noshow
    UPDATE [SIGSALUD].[dbo].[TARIFARIO_MAYO_2017]  SET precioa = ?lnprecioa, preciosis = ?lnpreciosis, preciosoat = ?lnpreciosoat WHERE nro = ?lnnro
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqty_graba_precio) 

  cMensage = '...TRABAJANDO PARA : ' +lccodcpt 
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
  

ENDSCAN

cMensage = '...PROCESO TERMINADO FINALMENTE.........' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
