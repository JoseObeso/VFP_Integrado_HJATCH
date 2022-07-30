** permite agregar cpt atencion  *
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
cMensage = '...procesando.......' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

***************************************************

TEXT TO lqry_ver_cpt noshow
  SELECT [CPT],[NOMBRE],[INDICADOR]  FROM [SIGSALUD].[dbo].[ATEN_MEDICA]
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_ver_cpt,"tver_cpt")
SELECT tver_cpt
GO top
SCAN
 lcodcpt = ALLTRIM(tver_cpt.cpt)
 TEXT TO lqry_ejecuta noshow
   update [SIGSALUD].[dbo].[ITEM] set clasificador = '1.3.34.11', GRUPO_LIQUIDACION = '01', GRUPO_RECAUDACION = '01' where codcpt = ?lcodcpt and SUBSTRING(item,1,1) = '6'
 ENDTEXT
 lejecutabusca = sqlexec(gconecta,lqry_ejecuta)   
 IF lejecutabusca > 0
   cMensage = '...OK, EJECUTADO..........'  +lcodcpt
   _Screen.Scalemode = 0
   Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
 ELSE
   cMensage = '...ERROR......'  +lcodcpt
   _Screen.Scalemode = 0
   Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
   TEXT TO lqry_mal noshow
    UPDATE [SIGSALUD].[dbo].[ATEN_MEDICA] SET INDICADOR = 'M' WHERE cpt = ?lcodcpt
   ENDTEXT
   lejecutabusca = sqlexec(gconecta,lqry_mal)    
  ENDIF

ENDSCAN
cMensage = '...PROCESO FINALIZADO ...'
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
