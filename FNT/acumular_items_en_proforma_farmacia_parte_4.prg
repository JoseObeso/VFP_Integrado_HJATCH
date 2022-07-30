clear
** Revisar las horas del turno ma�ana y tarde ******
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
  
cMensage = '...INICIANDO PROCESO.............' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  




   lc_transfer = '18000163' 
   TEXT TO lqry_ver_items noshow
      SELECT * FROM  TRANSFERENCIAD WHERE TRANSFERENCIAID = '18000163' 
   ENDTEXT
   lejecutabusca = sqlexec(gconecta,lqry_ver_items,"titems")     
   SELECT titems
   GO top
   SCAN
     lc_itemf = ALLTRIM(titems.item)
     lncanti = titems.cantidad
     TEXT TO lqry_update noshow
       DECLARE @lc_item VARCHAR(13) = ?lc_itemf 
       declare @lc_transfer varchar(20) = '18000163' 
       declare @ln_stock int = ?lncanti
       declare @ln_saldo int = (select top 1 SALDO from KARDEX where ITEM  = @lc_item AND IDTRANSACCION <> '18000163'  AND ALMACEN in ('C')  ORDER BY OPERACION DESC)
       DECLARE @lnsaldo_ingresar int = case when @ln_saldo is null then 0 else @ln_saldo end
       update KARDEX set stock = @lnsaldo_ingresar   where ITEM = @lc_item and IDTRANSACCION  = @lc_transfer AND ALMACEN = 'C'
     ENDTEXT
     lejecutabusca = sqlexec(gconecta,lqry_update)
     cMensage = '...PROCESANDO.. ..........'  + lc_itemf
     _Screen.Scalemode = 0
     Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
     
   ENDSCAN


cMensage = '...operacion FINALIZADA 4..........' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

