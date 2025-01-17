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


TEXT TO lqry_ver_proformas noshow
   select * from [SIGSALUD].[dbo].[ORDENC] where ORDENID IN ('1718005560', '1718005561', '1718005613', '1718005612', '1718005611', '1718005609', '1718005607', '1718005603',
     '1718005602', '1718005600', '1718005599', '1718005598', '1718005597', '1718005596', '1718005594', '1718005592', '1718005591', '1718005590', '1718005588', '1718005587',
     '1718005586', '1718005584', '1718005581', '1718005580', '1718005576') order by ORDENID 
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_ver_proformas,"tprofor")
SELECT tprofor
GO top
SCAN
   lc_proforma = ALLTRIM(tprofor.ordenid)
   lc_nombre = ALLTRIM(tprofor.nombre)
   TEXT TO lqry_ver_proformad noshow
     select * from [SIGSALUD].[dbo].[ORDEND] where ORDENID = ?lc_proforma order by ITEM 
   ENDTEXT
   lejecutabusca = sqlexec(gconecta,lqry_ver_proformad,"tproford")  
   SELECT tproford
   GO top
   SCAN
      lcitem = ALLTRIM(tproford.item)
      lncanti = tproford.cantidad
      lnprecio = tproford.precio
      TEXT TO lqry_detalle noshow
         declare @lcproforma varchar(10) = ?lc_proforma
         declare @lc_almacen char(2) = 'F'
         declare @lc_item varchar(10) = ?lcitem
         declare @lncantidad NUMERIC(18,2) = ?lncanti
         declare @ld_fecha datetime = CONVERT(datetime, '2018-01-04', 101) + CAST('12:01:00' AS DATETIME)
         declare @ld_fecha_proceso datetime = CONVERT(datetime, '2018-01-04', 101)
         declare @lt_hora_proceso time 
         declare @lc_tipo_transaccion varchar(3) = 'VC'
         DECLARE @lnstock_item NUMERIC(18,2) = (select stock from [SIGSALUD].[dbo].[STOCK] where ITEM =  @lc_item and  almacen = @lc_almacen)
         declare @lnsaldo NUMERIC(18,2) = @lnstock_item - @lncantidad
         declare @lnprecio numeric(18,5) = ?lnprecio
         declare @lnpromedio numeric(18,5) = 0.00
         declare @lc_laboratorio char(10) = '0'
         declare @lcmarca varchar(20) = ''
         declare @lclote varchar(20) = ''
         declare @lcregistro varchar(20) = ''
         declare @ldfechavencimiento datetime  = ''
         declare @lc_operacion char(9) = (select top 1 convert(int,  OPERACION)  from [SIGSALUD].[dbo].[KARDEX] order by OPERACION desc) + 1
         INSERT INTO [SIGSALUD].[dbo].[KARDEX]([ALMACEN],[ITEM],[FECHA],[TIPO_TRANSACCION],[IDTRANSACCION],[STOCK],[CANTIDAD],[SALDO],[PRECIO],[PROMEDIO],
                   [LABORATORIO],[MARCA],[LOTE],[REGISTRO],[FECHA_VENCIMIENTO],[OPERACION])
         values (@lc_almacen, @lc_item, @ld_fecha, @lc_tipo_transaccion, @lcproforma, @lnstock_item, @lncantidad, @lnsaldo, @lnprecio, @lnpromedio, @lc_laboratorio, @lcmarca, @lclote, @lcregistro, @ldfechavencimiento, @lc_operacion)
        UPDATE [SIGSALUD].[dbo].[STOCK] SET Stock= @lnsaldo WHERE Item=@lc_item And Almacen=@lc_almacen
        UPDATE [SIGSALUD].[dbo].[ORDENC]SET Estado='3', FECHA =@ld_fecha_proceso, Fecha_Proceso=@ld_fecha_proceso, Hora_Proceso=hora WHERE OrdenId= @lcproforma
        Update [SIGSALUD].[dbo].[ORDEND] set Estado='3' WHERE OrdenId= @lcproforma
      ENDTEXT 
     lejecutabusca = sqlexec(gconecta,lqry_detalle)  
     IF lejecutabusca > 0
        cMensage = '...INICIANDO PROCESO.............' 
        _Screen.Scalemode = 0
        Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
      ELSE
        cMensage = '...FALLA EN LA ACTUALIZACION STOCK ............' 
        _Screen.Scalemode = 0
        Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
      ENDIF
      
   
   ENDSCAN
      cMensage = '...PROFORMA PROCESADA : ......' +lc_proforma + '...de ...: ' + lc_nombre
      _Screen.Scalemode = 0
      Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

ENDSCAN

cMensage = '...ORDENACION... FINALIZADA ..........' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

