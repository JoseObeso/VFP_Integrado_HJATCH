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
  
  
  TEXT TO lqry_ver_stock NOSHOW
   truncate TABLE [SIGSALUD].[dbo].[TMP_TRANSFER]
   select ITEM, STOCK from [SIGSALUD].[dbo].[V_STOCK] where ALMACEN = 'F' and STOCK > 0 ORDER BY NOMBRE 
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqry_ver_stock,"tstock")
  SELECT tstock
  GO top
  SCAN
     lc_item = ALLTRIM(tstock.item)
     ln_stock = tstock.stock
     TEXT TO lqry_grabar noshow
        declare @ln_precio numeric(8,3) = (SELECT TOP 1 PRECIOPUB  FROM v_PRECIO WHERE ITEM = ?lc_item  ORDER BY FECHA DESC)
        DECLARE @ln_stock int = ?ln_stock
        INSERT INTO [SIGSALUD].[dbo].[TMP_TRANSFER]([TRANSFERENCIAID],[ITEM],[CANTIDAD],[PRECIO],[DESCUENTO],[IMPORTE],[LOTE],[FECHA_VCTO])
          VALUES ('18000163', ?lc_item, @ln_stock, @ln_precio, 0.00, @ln_stock * @ln_precio, '', '')
     ENDTEXT
     lejecutabusca = sqlexec(gconecta,lqry_grabar)     
     IF lejecutabusca > 0
       cMensage = '...GRABACION OK .......' +lc_item
       _Screen.Scalemode = 0
       Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

     ELSE
       cMensage = '...ERROR .......' +lc_item
       _Screen.Scalemode = 0
       Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
     
     ENDIF
     
     
  
  ENDSCAN
  
  
TEXT TO lqry_subir noshow
  DELETE FROM [SIGSALUD].[dbo].[TRANSFERENCIAD] WHERE TRANSFERENCIAID = '18000163' 
  INSERT INTO [SIGSALUD].[dbo].[TRANSFERENCIAD]([TRANSFERENCIAID],[ITEM],[CANTIDAD],[PRECIO],[DESCUENTO],[IMPORTE],[LOTE],[FECHA_VCTO])
  SELECT * FROM [SIGSALUD].[dbo].[TMP_TRANSFER]
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_subir)       

TEXT TO lqry_actualiza_saldos noshow
  declare @lsumtotal numeric(18,3) = (SELECT SUM(IMPORTE)  FROM  TRANSFERENCIAD WHERE TRANSFERENCIAID = '18000163') 
  update [SIGSALUD].[dbo].[TRANSFERENCIAC] set SUBTOTAL = @lsumtotal, TOTAL = @lsumtotal, estado = '2' WHERE TRANSFERENCIAID = '18000163' 
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_actualiza_saldos)         



cMensage = '...PROCESO TERMINADO ......'
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  




