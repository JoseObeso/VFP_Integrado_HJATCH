clear
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


TEXT TO lqry_ver_transaccion noshow
  TRUNCATE TABLE  [SIGSALUD].[dbo].[TABLA_AEM_2017] 
  select INGRESOID, FECHA, DOCUMENTO, OBSERVACION AS FUENTE_DE_FINANCIAMIENTO, MODALIDAD_COMPRA, PPA, CONVERT(varchar(10), fecha, 103) as fecha_ingreso 
    FROM INGRESOC where TIPO_TRANSACCION = 'ICO' AND FECHA BETWEEN CONVERT(DATETIME, '2018-01-01', 101) AND CONVERT(DATETIME, '2018-03-23', 101)
     order by FECHA 
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_ver_transaccion,"ttransac")
SELECT ttransac
GO top
SCAN
  lc_ingreso = ALLTRIM(ttransac.ingresoid)
  lc_nro_ppa = ALLTRIM(ttransac.ppa)
  lc_orden_compra = ALLTRIM(ttransac.documento)
  lc_fuente_financiamiento = ALLTRIM(ttransac.FUENTE_DE_FINANCIAMIENTO)
  lc_tipo_de_compra = ALLTRIM(ttransac.modalidad_compra)
  lc_fecha_ingreso_almacen = ALLTRIM(ttransac.fecha_ingreso)
  TEXT TO lqry_ver_kardex1 noshow
    select ITEM, IDTRANSACCION, PRECIO as precio_costo, LOTE, convert(varchar(10), fecha_vencimiento, 103) as fecha_ven from KARDEX where FECHA BETWEEN CONVERT(DATETIME, '2018-01-01', 101) + CAST('00:00:00' AS DATETIME)
      AND CONVERT(DATETIME, '2018-03-23', 101) + CAST('23:59:59' AS DATETIME)  and IDTRANSACCION = ?lc_ingreso
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqry_ver_kardex1,"tt1")
  SELECT tt1
  GO top
  SCAN
    lc_item = ALLTRIM(tt1.ITEM)
    ln_precio_costo = tt1.precio_costo
    lc_lote = ALLTRIM(tt1.lote)
    lc_fecha_vencimiento = ALLTRIM(tt1.fecha_ven)
    TEXT TO lver_precio noshow
      select top 1 PRECIO as precio_operacion from KARDEX where FECHA BETWEEN CONVERT(DATETIME, '2018-01-01', 101) + CAST('00:00:00' AS DATETIME)
        AND CONVERT(DATETIME, '2018-03-23', 101) + CAST('23:59:59' AS DATETIME)  and ITEM = ?lc_item and ALMACEN = 'F' order by OPERACION desc
    ENDTEXT
    lejecutabusca = sqlexec(gconecta,lver_precio, "tpre")
    SELECT tpre
    ln_precio_operacion = tpre.precio_operacion
    
    TEXT TO lver_stock noshow
      select convert(varchar(10), convert(date, fecha, 103) + CAST('00:00:00' AS DATETIME), 103)  as Fecha_termino_stock  from KARDEX where FECHA BETWEEN CONVERT(DATETIME, '2018-01-01', 101) + CAST('00:00:00' AS DATETIME)
        AND CONVERT(DATETIME, '2018-03-23', 101) + CAST('23:59:59' AS DATETIME)  and  item = ?lc_item  and ALMACEN = 'A' and SALDO = 0
    ENDTEXT
    lejecutabusca = sqlexec(gconecta,lver_stock, "tstock")
    SELECT tpre
    lc_fecha_termino_stock = tstock.Fecha_termino_stock
    
    TEXT TO lver_sismed noshow
      select nombre, interfase2 from ITEM where ITEM = ?lc_item 
    ENDTEXT
    lejecutabusca = sqlexec(gconecta,lver_sismed, "tsismed")
    SELECT tsismed
    lc_sismed = ALLTRIM(tsismed.interfase2)
    lc_descripcion = ALLTRIM(tsismed.nombre)

    TEXT TO lc_insertar noshow
      INSERT INTO [SIGSALUD].[dbo].[TABLA_AEM_2017]([CODIGO_SISMED],[DESCRIPCION_ITEM],[NRO_PPA],[NRO_LOTE],[NRO_O_C],[NRO_CARTA_ORDEN],[PRECIO_COMPRA],[PRECIO_OPERACION],[FECHA_INGRESO_ALMACEN],
          [FECHA_VENCIMIENTO],[FECHA_TERMINO_STOCK],[FUENTE_FINANCIAMIENTO],[TIPO_DE_COMPRA])
      VALUES (?lc_sismed, ?lc_descripcion, ?lc_nro_ppa, ?lc_lote, ?lc_orden_compra, '', ?ln_precio_costo, ?ln_precio_operacion, ?lc_fecha_ingreso_almacen, ?lc_fecha_vencimiento, ?lc_fecha_termino_stock, ?lc_fuente_financiamiento, ?lc_tipo_de_compra)  
    ENDTEXT
    lejecutabusca = sqlexec(gconecta,lc_insertar)
    IF lejecutabusca > 0
      cMensage = '...GRABACION CONFORME : ' + lc_sismed 
      _Screen.Scalemode = 0
       Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
    ELSE
      cMensage = '...ERROR DE GRABACION...' 
      _Screen.Scalemode = 0
      Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
    ENDIF
    
  ENDSCAN
    
    
ENDSCAN
 

cMensage = '...PROCESAMIENTO. FINALIZADA ..........' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

