* TOTAL_SALIDA *
* ventas_contado
* procesar ICI PARA VER DIFERENCIAS *

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

* Rutina para ejecutar Pre ICI
lcoperacioninicial = '18079845'
lcoperacionfinal = '18135030'

lcfechainicio = '2018'  + '-'  +  '02'  + '-' + '28'
lcfechafin =  '2018'  + '-'  +  '03'  + '-' + '28'
lcuser = "Jobeso"

lcfechainicio_mostrar = '28' + '/' + '02' + '/' + '2018'
lcfechafin_mostrar =  '28' + '/' + '03' + '/' + '2018'

cMensage = ' ...INICIANDO PROCESAMIENTO......' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait
  

TEXT TO lobtener_items noshow
  truncate table  [SIGSALUD].[dbo].[TMP_PRE_ICI]
  INSERT INTO [SIGSALUD].[dbo].[TMP_PRE_ICI]([CLASE],[NOMBRE_CLASE], [ITEM], [SISMED], [NOMBRE], [PRESENTACION], DFECHA_INICIO_PROCESO)
  select b.CLASE, b.NOMBRE as NOMBRE_CLASE, a.ITEM, A.interfase2 AS SISMED, UPPER(a.NOMBRE) as nombre, UPPER(A.PRESENTACION) AS PRESENTACION, GETDATE() AS DFECHA_INICIO_PROCESO
	     from [SIGSALUD].[dbo].[ITEM] a   left join [SIGSALUD].[dbo].[CLASE] b on a.CLASE = b.CLASE where  SUBSTRING(A.item,1,2) = '17' and A.ITEM = '170648' 
 SELECT * FROM [SIGSALUD].[dbo].[TMP_PRE_ICI] ORDER BY NOMBRE ASC
ENDTEXT
lejecuta=SQLEXEC(gconecta,lobtener_items,"titems") 
SELECT titems
GO top
SCAN
 lcitem = ALLTRIM(titems.item)
 lcnombre = ALLTRIM(titems.nombre)
 * obtener el stock del almacen 
 TEXT TO lver_stock_almacen noshow
   declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
   declare @lfechafin datetime = convert(datetime, ?lcfechafin,101) + CAST('23:59:59' AS DATETIME)
   declare @lcitem varchar(13) = ?lcitem
   SELECT top 1 SALDO as STOCK_ALMACEN FROM [SIGSALUD].[dbo].[KARDEX] WHERE ITEM = @lcitem AND ALMACEN = 'A'  and fecha between @lfechainicio and @lfechafin ORDER BY FECHA DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_almacen,"tstock1") 
 SELECT tstock1
 nr1 = RECCOUNT()
 IF nr1 = 0
   TEXT TO lver_stock2 noshow
    declare @lcitem varchar(13) = ?lcitem
    declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
    SELECT TOP 1 SALDO AS STOCK_ALMACEN FROM [SIGSALUD].[dbo].[KARDEX] WHERE ITEM = @lcitem AND ALMACEN = 'A' AND FECHA < @lfechainicio  ORDER BY FECHA DESC
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_stock2,"tstock2") 
   SELECT tstock2
   nr2 = reccount()
   IF nr2 = 0
      litem_stock_almacen = 0
   ELSE
      litem_stock_almacen = tstock2.stock_almacen
   ENDIF
 ELSE
   litem_stock_almacen = tstock1.stock_almacen
 ENDIF
 * Grabar stock en el archivo pre_ici
  TEXT TO lactualiza_stock_almacen noshow
    UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET stock_almacen = ?litem_stock_almacen WHERE item = ?lcitem
  ENDTEXT
  lejecuta=SQLEXEC(gconecta,lactualiza_stock_almacen)


**** INICIO - FARMACIA 
*************************************
**** VER EL STOCK DE FARMACIA ***********
 TEXT TO lver_stock_farmacia NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = 'F' and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia,"tstockfar") 
 SELECT tstockfar
 nf1 = RECCOUNT()
 IF nf1 = 0
   TEXT TO lver_sf2 noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = 'F' AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2,"tsf2")
   SELECT tsf2
   nf2 = RECCOUNT()
   IF nf2 = 0
      litem_stock_farmacia = 0
   ELSE
      litem_stock_farmacia = tsf2.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia = tstockfar.stock_farmacia
 ENDIF
 ** Actualizar Stock Farmacia
 TEXT TO lactualiza_stock_farmacia noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET stock_farmacia = ?litem_stock_farmacia WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lactualiza_stock_farmacia)
 
*** INICIO DE STOCK EN CONSULTORIOS ***
*************************************
 TEXT TO lver_stock_farmacia_c NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = 'C' and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_c,"tstockfar_c") 
 SELECT tstockfar_c
 nf1_c = RECCOUNT()
 IF nf1_c = 0
   TEXT TO lver_sf2_c noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = 'C' AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_c,"tsf2_c")
   SELECT tsf2_c
   nf2_c = RECCOUNT()
   IF nf2_c = 0
      litem_stock_farmacia_c = 0
   ELSE
      litem_stock_farmacia_c = tsf2_c.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_c = tstockfar_c.stock_farmacia
 ENDIF
 ** Actualizar Stock Farmacia
 TEXT TO lactualiza_stock_farmacia_c noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET STOCK_CONSULTORIOS = ?litem_stock_farmacia_c WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lactualiza_stock_farmacia_c)
*** FIN DE STOCK EN CONSULTORIOS 

 
*** PARA SO
*************************************
lc_almacen = 'SO'
 TEXT TO lver_stock_farmacia_so NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_so,"tstockfar_so") 
 SELECT tstockfar_so
 nf1_so = RECCOUNT()
 IF nf1_so = 0
   TEXT TO lver_sf2_so noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_so,"tsf2_so")
   SELECT tsf2_so
   nf2_so = RECCOUNT()
   IF nf2_so = 0
      litem_stock_farmacia_so = 0
   ELSE
      litem_stock_farmacia_so = tsf2_so.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_so = tstockfar_so.stock_farmacia
 ENDIF



*** PARA CI
*************************************
lc_almacen = 'CI'
 TEXT TO lver_stock_farmacia_ci NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_ci,"tstockfar_ci") 
 SELECT tstockfar_ci
 nf1_ci = RECCOUNT()
 IF nf1_ci = 0
   TEXT TO lver_sf2_ci noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_ci,"tsf2_ci")
   SELECT tsf2_ci
   nf2_ci = RECCOUNT()
   IF nf2_ci = 0
      litem_stock_farmacia_ci = 0
   ELSE
      litem_stock_farmacia_ci = tsf2_ci.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_ci = tstockfar_ci.stock_farmacia
 ENDIF



*** PARA GO
*************************************
lc_almacen = 'GO'
 TEXT TO lver_stock_farmacia_go NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_go,"tstockfar_go") 
 SELECT tstockfar_go
 nf1_go = RECCOUNT()
 IF nf1_go = 0
   TEXT TO lver_sf2_go noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_go,"tsf2_go")
   SELECT tsf2_go
   nf2_go = RECCOUNT()
   IF nf2_go = 0
      litem_stock_farmacia_go = 0
   ELSE
      litem_stock_farmacia_go = tsf2_go.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_go = tstockfar_go.stock_farmacia
 ENDIF


*******
*** PARA PE
*************************************
lc_almacen = 'PE'
 TEXT TO lver_stock_farmacia_pe NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_pe,"tstockfar_pe") 
 SELECT tstockfar_pe
 nf1_pe = RECCOUNT()
 IF nf1_pe = 0
   TEXT TO lver_sf2_pe noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_pe,"tsf2_pe")
   SELECT tsf2_pe
   nf2_pe = RECCOUNT()
   IF nf2_pe = 0
      litem_stock_farmacia_pe = 0
   ELSE
      litem_stock_farmacia_pe = tsf2_pe.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_pe = tstockfar_pe.stock_farmacia
 ENDIF
******


******
*******
*** PARA ME
*************************************
lc_almacen = 'ME'
 TEXT TO lver_stock_farmacia_me NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_me,"tstockfar_me") 
 SELECT tstockfar_me
 nf1_me = RECCOUNT()
 IF nf1_me = 0
   TEXT TO lver_sf2_me noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_me,"tsf2_me")
   SELECT tsf2_me
   nf2_me = RECCOUNT()
   IF nf2_me = 0
      litem_stock_farmacia_me = 0
   ELSE
      litem_stock_farmacia_me = tsf2_me.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_me = tstockfar_me.stock_farmacia
 ENDIF


******



*** PARA NE
*************************************
lc_almacen = 'NE'
 TEXT TO lver_stock_farmacia_ne NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_ne,"tstockfar_ne") 
 SELECT tstockfar_ne
 nf1_ne = RECCOUNT()
 IF nf1_ne = 0
   TEXT TO lver_sf2_ne noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_ne,"tsf2_ne")
   SELECT tsf2_ne
   nf2_ne = RECCOUNT()
   IF nf2_ne = 0
      litem_stock_farmacia_ne = 0
   ELSE
      litem_stock_farmacia_ne = tsf2_ne.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_ne = tstockfar_ne.stock_farmacia
 ENDIF


******

***********
*** PARA UC
*************************************
lc_almacen = 'UC'
 TEXT TO lver_stock_farmacia_uc NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_uc,"tstockfar_uc") 
 SELECT tstockfar_uc
 nf1_uc = RECCOUNT()
 IF nf1_uc = 0
   TEXT TO lver_sf2_uc noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_uc,"tsf2_uc")
   SELECT tsf2_uc
   nf2_uc = RECCOUNT()
   IF nf2_uc = 0
      litem_stock_farmacia_uc = 0
   ELSE
      litem_stock_farmacia_uc = tsf2_uc.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_uc = tstockfar_uc.stock_farmacia
 ENDIF
******

***********
*** PARA EM
*************************************
lc_almacen = 'EM'
 TEXT TO lver_stock_farmacia_em NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_em,"tstockfar_em") 
 SELECT tstockfar_em
 nf1_em = RECCOUNT()
 IF nf1_em = 0
   TEXT TO lver_sf2_em noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_em, "tsf2_em")
   SELECT tsf2_em
   nf2_em = RECCOUNT()
   IF nf2_em = 0
      litem_stock_farmacia_em = 0
   ELSE
      litem_stock_farmacia_em = tsf2_em.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_em = tstockfar_em.stock_farmacia
 ENDIF
******


***********
*** PARA AM
*************************************
lc_almacen = 'AM'
 TEXT TO lver_stock_farmacia_am NOSHOW
   declare @loperacion1 varchar(8) = ?lcoperacioninicial
   declare @loperacion2 varchar(8) = ?lcoperacionfinal
   declare @lcitemfar varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen and OPERACION between @loperacion1 and @loperacion2 order by operacion desc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_stock_farmacia_am,"tstockfar_am") 
 SELECT tstockfar_am
 nf1_am = RECCOUNT()
 IF nf1_am = 0
   TEXT TO lver_sf2_am noshow
      declare @lcitemfar varchar(13) = ?lcitem
      declare @lfechainicio datetime = convert(datetime, ?lcfechainicio,101) +  CAST('00:00:00' AS DATETIME)
      select top 1 SALDO as STOCK_FARMACIA  from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfar and ALMACEN = ?lc_almacen AND FECHA < @lfechainicio order by operacion desc
   ENDTEXT
   lejecuta=SQLEXEC(gconecta,lver_sf2_am, "tsf2_am")
   SELECT tsf2_am
   nf2_am = RECCOUNT()
   IF nf2_am = 0
      litem_stock_farmacia_am = 0
   ELSE
      litem_stock_farmacia_am = tsf2_am.stock_farmacia
   ENDIF
 ELSE
   litem_stock_farmacia_am = tstockfar_am.stock_farmacia
 ENDIF
******

**********

 
 
** Actualizar Stock COCHE
ln_stock_coche = litem_stock_farmacia_so + litem_stock_farmacia_ci + litem_stock_farmacia_go +    litem_stock_farmacia_pe + litem_stock_farmacia_me + litem_stock_farmacia_ne + litem_stock_farmacia_uc +    litem_stock_farmacia_am
****
 TEXT TO lactualiza_stock_farmacia_so noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET STOCK_COCHE = ?ln_stock_coche WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lactualiza_stock_farmacia_so)
*** FIN DE COCHE



 ************* SUMA STOCK PARA EL TOTAL *******
 * Ver Stock Total
 lstock_total =  litem_stock_almacen + litem_stock_farmacia + litem_stock_farmacia_c + ln_stock_coche
 TEXT TO lactualiza_stock_total noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET stock_total = ?lstock_total WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lactualiza_stock_total)




 **  Buscar Precio
 TEXT TO lver_precio noshow
  declare @lcitemprecio varchar(13) = ?lcitem
  SELECT TOP 1 PRECIOPUB FROM [SIGSALUD].[dbo].[PRECIO] where ITEM = @lcitemprecio ORDER BY FECHA DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_precio, "tprec")
 SELECT tprec
 npre = RECCOUNT()
 IF npre = 0
   lprecioitem = 0
 ELSE
   lprecioitem = tprec.preciopub
 ENDIF
  * Graba Precio en Item
 TEXT TO lgraba_precio noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET precio = ?lprecioitem WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lgraba_precio)

  * Limpiando Precios 
 TEXT TO lclear_precio noshow
     update [SIGSALUD].[dbo].[TMP_PRE_ICI] set precio = 0 where precio is null
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lclear_precio)
 
**** FIN DE PRECIOS



 * Iniciando el calculo de stock del mes anterior *
 
 * Almacen
 TEXT TO lstock_al_anterior noshow
   declare @lfechastock_anterior datetime = convert(datetime, ?lcfechainicio,101) + CAST('00:00:00' AS DATETIME)
   declare @lcitemante varchar(13) = ?lcitem
   SELECT top 1 SALDO as STOCK_ALMACEN FROM [SIGSALUD].[dbo].[KARDEX] WHERE ITEM = @lcitemante AND ALMACEN = 'A'  and fecha < @lfechastock_anterior ORDER BY FECHA DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_al_anterior, "tstocka")
 SELECT tstocka
 nra = RECCOUNT()
 IF nra = 0
   lstock_a = 0
 ELSE
   lstock_a = tstocka.stock_almacen
 ENDIF
 * Farmacia
  TEXT TO lstock_f noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = 'F' and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f, "tstockf")  
 SELECT tstockf
 nfa = RECCOUNT()
 IF nfa = 0
   lstock_fa = 0
 ELSE
   lstock_fa = tstockf.stock_farmacia
 ENDIF
 
 * CONSULTORIOS 
  TEXT TO lstock_f_c noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = 'C' and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_c, "tstockf_c")  
 SELECT tstockf_c
 nfa_c = RECCOUNT()
 IF nfa_c = 0
   lstock_fa_c = 0
 ELSE
   lstock_fa_c = tstockf_c.stock_farmacia
 ENDIF
  lstock_ante_total = lstock_a + lstock_fa + lstock_fa_c
 
* so
lc_almacen_stock = 'SO'
  TEXT TO lstock_f_so noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_so, "tstockf_so")  
 SELECT tstockf_so
 nfa_so = RECCOUNT()
 IF nfa_so = 0
   lstock_fa_so = 0
 ELSE
   lstock_fa_so = tstockf_so.stock_farmacia
 ENDIF
 **** fin de stock so 
 
********
* CI
lc_alamacen_stock = 'CI'
  TEXT TO lstock_f_ci noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_ci, "tstockf_ci")  
 SELECT tstockf_ci
 nfa_ci = RECCOUNT()
 IF nfa_ci = 0
   lstock_fa_ci = 0
 ELSE
   lstock_fa_ci = tstockf_ci.stock_farmacia
 ENDIF
 **** fin de stock ci
  

********
* GO
lc_alamacen_stock = 'GO'
  TEXT TO lstock_f_go noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_go, "tstockf_go")  
 SELECT tstockf_go
 nfa_go = RECCOUNT()
 IF nfa_go = 0
   lstock_fa_go = 0
 ELSE
   lstock_fa_go = tstockf_go.stock_farmacia
 ENDIF
 **** fin de stock go
 
 
********
* PE
lc_alamacen_stock = 'PE'
  TEXT TO lstock_f_pe noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_pe, "tstockf_pe")  
 SELECT tstockf_pe
 nfa_pe = RECCOUNT()
 IF nfa_pe = 0
   lstock_fa_pe = 0
 ELSE
   lstock_fa_pe = tstockf_pe.stock_farmacia
 ENDIF
 **** fin de stock pe
 
********
* ME
lc_alamacen_stock = 'ME'
  TEXT TO lstock_f_me noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_me, "tstockf_me")  
 SELECT tstockf_me
 nfa_me = RECCOUNT()
 IF nfa_me = 0
   lstock_fa_me = 0
 ELSE
   lstock_fa_me = tstockf_me.stock_farmacia
 ENDIF
 **** fin de stock me

****
********
* NE
lc_alamacen_stock = 'NE'
  TEXT TO lstock_f_ne noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_ne, "tstockf_ne")  
 SELECT tstockf_ne
 nfa_ne = RECCOUNT()
 IF nfa_ne = 0
   lstock_fa_ne = 0
 ELSE
   lstock_fa_ne = tstockf_ne.stock_farmacia
 ENDIF
 **** fin de stock ne
 
********
* UC
lc_alamacen_stock = 'UC'
  TEXT TO lstock_f_uc noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_uc, "tstockf_uc")  
 SELECT tstockf_uc
 nfa_uc = RECCOUNT()
 IF nfa_uc = 0
   lstock_fa_uc = 0
 ELSE
   lstock_fa_uc = tstockf_uc.stock_farmacia
 ENDIF
 **** fin de stock uc
 
********
* EM
lc_alamacen_stock = 'EM'
  TEXT TO lstock_f_em noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_em, "tstockf_em")  
 SELECT tstockf_em
 nfa_em = RECCOUNT()
 IF nfa_em = 0
   lstock_fa_em = 0
 ELSE
   lstock_fa_em = tstockf_em.stock_farmacia
 ENDIF
 **** fin de stock em


********
* AM
lc_alamacen_stock = 'AM'
  TEXT TO lstock_f_am noshow
   declare @loperacion1a varchar(8) = ?lcoperacioninicial
   declare @lcitemfara varchar(13) = ?lcitem
   select top 1 SALDO as STOCK_FARMACIA from [SIGSALUD].[dbo].[KARDEX] where ITEM = @lcitemfara and ALMACEN = ?lc_almacen_stock and OPERACION < @loperacion1a ORDER BY operacion DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lstock_f_am, "tstockf_am")  
 SELECT tstockf_am
 nfa_am = RECCOUNT()
 IF nfa_am = 0
   lstock_fa_am = 0
 ELSE
   lstock_fa_am = tstockf_am.stock_farmacia
 ENDIF
 **** fin de stock am

 
 lstock_ante_total = lstock_a + lstock_fa + lstock_fa_c + lstock_fa_so + lstock_fa_ci + lstock_fa_go + lstock_fa_pe + lstock_fa_me + lstock_fa_ne + lstock_fa_uc + lstock_fa_em + lstock_fa_am  
 
 

**** fin de so 
 


 * Grabar Stock Total Anterior 
 TEXT TO lactualiza_stock_total_a noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET saldo_mes_anterior  = ?lstock_ante_total WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lactualiza_stock_total_a)
 
 
 * REVISAR INGRESO POR ITEM *

 TEXT TO lrevisar_item noshow
   declare @litem varchar(13) = ?lcitem
   DECLARE @lfecha1 datetime = convert(datetime, ?lcfechainicio,101)  +  CAST('00:00:00' AS DATETIME)
   DECLARE @lfecha2 datetime = convert(datetime, ?lcfechafin,101) + CAST('23:59:59' AS DATETIME)
   SELECT SUM(CANTIDAD) AS CANTI FROM [SIGSALUD].[dbo].[INGRESOD] WHERE INGRESOID IN (SELECT INGRESOID FROM [SIGSALUD].[dbo].[INGRESOC] WHERE FECHA BETWEEN @lfecha1 AND @lfecha2) AND ITEM = @litem  GROUP BY ITEM 
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lrevisar_item, "tingre")
 SELECT tingre
 ningre = RECCOUNT()
 IF ningre = 0
    lningreso = 0
 ELSE
    lningreso = tingre.canti
 ENDIF
    
 * Grabar ingreso por item 
 TEXT TO lgrabar_ingreso noshow
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET INGRESO_ITEM_ALMACEN  = ?lningreso WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lgrabar_ingreso)
    

*     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET TOTAL_SALIDA  = SALDO_MES_ANTERIOR + INGRESO_ITEM_ALMACEN - STOCK_TOTAL
* Grabando Total Salida, saldo final 
 TEXT TO ltotal_salida noshow
    UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET TOTAL_SALIDA  = ventas_contado + credito_paciente + total_sis + intervencion_sanitaria + soat + exonerado 
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET SALDO_FINAL  = STOCK_TOTAL
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,ltotal_salida)
 
 TEXT TO lver_fecha_venci NOSHOW
   declare @litem varchar(13) = ?lcitem
   SELECT TOP 1 CONVERT(VARCHAR(10), FECHA_VENCIMIENTO, 103) AS FECHA_VENCI  FROM [SIGSALUD].[dbo].[INGRESOD] WHERE ITEM = @litem  ORDER BY FECHA_VENCIMIENTO DESC
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_fecha_venci, "tvenci")
 SELECT tvenci
 lcfecha_vencimiento = ALLTRIM(tvenci.FECHA_VENCI)
 TEXT TO lgraba_venci noshow
   UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET FECHA_VENCIMIENTO  = ?lcfecha_vencimiento WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lgraba_venci)
 
 ** VER LOS DATOS DE PARTE DIARIO *
 TEXT TO lver_diario noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lalmacen varchar(1) = 'F'
   select k.item,SALDO_ANTIGUO = 0, i.nombre,MAX(k.PRECIO) AS Precio, sum((case when k.Tipo_Transaccion='VC' then k.Cantidad else 0 end)) as Salidas_Contado,
         sum((case when k.Tipo_Transaccion='VEX' then k.Cantidad else 0 end)) as Salidas_Exonerado, sum((case when k.Tipo_Transaccion='VRP' then k.Cantidad else 0 end)) as Salidas_Credito_Paciente,
           sum((case when k.Tipo_Transaccion='VRS' then k.Cantidad else 0 end)) as Salidas_SIS, sum((case when k.Tipo_Transaccion='VRI' then k.Cantidad else 0 end)) as Salidas_SISALUD,
            sum((case when k.Tipo_Transaccion='VRO' then k.Cantidad else 0 end)) as Salidas_SOAT,sum((case when k.Tipo_Transaccion='VRD' then k.Cantidad else 0 end)) as Salidas_ConsPeru,
              sum((case when k.Tipo_Transaccion='VOI' then k.Cantidad else 0 end)) as Salidas_Sanitaria, sum((case when k.Tipo_Transaccion='VTB' then k.Cantidad else 0 end)) as Salidas_BTB,
                sum((case when k.Tipo_Transaccion='VOP' then k.Cantidad else 0 end)) as Salidas_Prg,sum((case when k.Tipo_Transaccion='VOD' then k.Cantidad else 0 end)) as Salidas_Dona,
                   sum((case when k.Tipo_Transaccion='ITR' then k.Cantidad else 0 end)) as Ingreso_Transfiere, sum((case when k.Tipo_Transaccion='IDE' then k.Cantidad else 0 end)) as Ingreso_Devolucion,
                      sum((case when k.Tipo_Transaccion='IAN' then k.Cantidad else 0 end)) as Ingreso_Anula, (select k1.Saldo from kardex k1 where k1.operacion=(select max(k2.Operacion) from Kardex k2 Where
                          k2.Operacion Between  @opeinicio and  @opefin and k2.almacen=@lalmacen and k2.Item=k1.item) and k.Item=k1.item) as Saldo,I.Clase,UPPER(C.Nombre) as Nombre_Clase, 
                          sum((case when k.Tipo_Transaccion='VOC' then k.Cantidad else 0 end)) as CANJE, i.interfase2 as sismed  from [SIGSALUD].[dbo].[V_KARDEX] k left outer join [SIGSALUD].[dbo].[TIPO_TRANSACCION] t on t.tipo_transaccion=k.Tipo_Transaccion   left outer join item i on i.item=k.Item left outer join clase c on c.clase=i.clase 
                                     where k.item = ?lcitem and k.Operacion between @opeinicio and @opefin and k.almacen=@lalmacen  group by k.item,i.nombre,i.clase,i.interfase2, c.nombre order by Clase, NOMBRE asc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_diario, "tdiario")
 SELECT tdiario
 lnsc1 = tdiario.Salidas_Contado
 lncp1 = tdiario.salidas_credito_paciente
 lnsis1 = tdiario.salidas_sis
 lndosis_unitaria1 = tdiario.salidas_consperu
 lnintervencion_sanitaria1 = tdiario.salidas_sanitaria + tdiario.salidas_BTB + tdiario.Salidas_Prg
 lnsoat1 = tdiario.salidas_soat
 lnexonerado1 = tdiario.salidas_exonerado
 ling_devo1 = tdiario.Ingreso_Devolucion
 
 
 
 ******
 ** VER LOS DATOS DE PARTE DIARIO **  CONSULTORIO 
 *************************************************
  TEXT TO lver_diario_C noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lalmacen varchar(1) = 'C'
   select k.item,SALDO_ANTIGUO = 0, i.nombre,MAX(k.PRECIO) AS Precio, sum((case when k.Tipo_Transaccion='VC' then k.Cantidad else 0 end)) as Salidas_Contado,
         sum((case when k.Tipo_Transaccion='VEX' then k.Cantidad else 0 end)) as Salidas_Exonerado, sum((case when k.Tipo_Transaccion='VRP' then k.Cantidad else 0 end)) as Salidas_Credito_Paciente,
           sum((case when k.Tipo_Transaccion='VRS' then k.Cantidad else 0 end)) as Salidas_SIS, sum((case when k.Tipo_Transaccion='VRI' then k.Cantidad else 0 end)) as Salidas_SISALUD,
            sum((case when k.Tipo_Transaccion='VRO' then k.Cantidad else 0 end)) as Salidas_SOAT,sum((case when k.Tipo_Transaccion='VRD' then k.Cantidad else 0 end)) as Salidas_ConsPeru,
              sum((case when k.Tipo_Transaccion='VOI' then k.Cantidad else 0 end)) as Salidas_Sanitaria, sum((case when k.Tipo_Transaccion='VTB' then k.Cantidad else 0 end)) as Salidas_BTB,
                sum((case when k.Tipo_Transaccion='VOP' then k.Cantidad else 0 end)) as Salidas_Prg,sum((case when k.Tipo_Transaccion='VOD' then k.Cantidad else 0 end)) as Salidas_Dona,
                   sum((case when k.Tipo_Transaccion='ITR' then k.Cantidad else 0 end)) as Ingreso_Transfiere, sum((case when k.Tipo_Transaccion='IDE' then k.Cantidad else 0 end)) as Ingreso_Devolucion,
                      sum((case when k.Tipo_Transaccion='IAN' then k.Cantidad else 0 end)) as Ingreso_Anula, (select k1.Saldo from kardex k1 where k1.operacion=(select max(k2.Operacion) from Kardex k2 Where
                          k2.Operacion Between  @opeinicio and  @opefin and k2.almacen=@lalmacen and k2.Item=k1.item) and k.Item=k1.item) as Saldo,I.Clase,UPPER(C.Nombre) as Nombre_Clase, 
                          sum((case when k.Tipo_Transaccion='VOC' then k.Cantidad else 0 end)) as CANJE, i.interfase2 as sismed  from [SIGSALUD].[dbo].[V_KARDEX] k left outer join [SIGSALUD].[dbo].[TIPO_TRANSACCION] t on t.tipo_transaccion=k.Tipo_Transaccion   left outer join item i on i.item=k.Item left outer join clase c on c.clase=i.clase 
                                     where k.item = ?lcitem and k.Operacion between @opeinicio and @opefin and k.almacen=@lalmacen  group by k.item,i.nombre,i.clase,i.interfase2, c.nombre order by Clase, NOMBRE asc
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_diario_c, "tdiario_c")
 SELECT tdiario_c
 lnsc2 = tdiario_c.Salidas_Contado
 lncp2 = tdiario_c.salidas_credito_paciente
 lnsis2 = tdiario_c.salidas_sis
 lndosis_unitaria2 = tdiario_c.salidas_consperu
 lnintervencion_sanitaria2 = tdiario_c.salidas_sanitaria + tdiario_c.salidas_BTB + tdiario_c.Salidas_Prg
 lnsoat2 = tdiario_c.salidas_soat
 lnexonerado2 = tdiario_c.salidas_exonerado
 ling_devo2 = tdiario_c.Ingreso_Devolucion
  
 *****
 lnsc =  lnsc1 +  lnsc2
 lncp = lncp1 + lncp2
 lnsis = lnsis1 + lnsis2
 lndosis_unitaria = lndosis_unitaria1 + lndosis_unitaria2
 lnintervencion_sanitaria =  lnintervencion_sanitaria1 +  lnintervencion_sanitaria2
 lnsoat = lnsoat1 + lnsoat2
 lnexonerado = lnexonerado1 + lnexonerado2
 ling_devo = ling_devo1 + ling_devo2
 
*******************
 
 TEXT TO lver_tansferencia noshow
   DECLARE @lfecha1 datetime = convert(datetime, ?lcfechainicio,101)  +  CAST('00:00:00' AS DATETIME)
   DECLARE @lfecha2 datetime = convert(datetime, ?lcfechafin,101) + CAST('23:59:59' AS DATETIME)
   Declare @litem varchar(6) = ?lcitem
   select SUM(CANTIDAD) AS TRANSFERENCIA from [SIGSALUD].[dbo].[KARDEX]
     where ITEM = @litem AND tipo_transaccion in ('STE', 'SPR', 'SCJ', 'SPD', 'SRO', 'STI', 'STN', 'SVN') AND ALMACEN = 'A' AND FECHA  BETWEEN @lfecha1 AND @lfecha2 GROUP BY ITEM 
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lver_tansferencia, "ttra")
 SELECT  ttra
 lncanti_trans = ttra.TRANSFERENCIA
 
 * CALCULAR LOS ANULADOS CONTADOS  - farmacia
 TEXT TO lqry_ver_anulados_contado noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lcitem varchar(13) =  ?lcitem
    select SUM(CANTIDAD) as ANULA_CONTADO  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'F' 
       AND B.MODULO = 'FARMACIA' AND TIPO_TRANSACCION IN ('IAN')  AND A.ESTADO  = 0 group by ITEM 
ENDTEXT
lejecuta=SQLEXEC(gconecta,lqry_ver_anulados_contado, "tanul_contado")
SELECT  tanul_contado
nf = RECCOUNT()
IF nf > 0 
  lnanulado_contado_f = tanul_contado.ANULA_CONTADO
ELSE
  lnanulado_contado_f = 0
ENDIF

 * CALCULAR LOS ANULADOS CONTADOS  - consultorio
 TEXT TO lqry_ver_anulados_contado_c noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lcitem varchar(13) =  ?lcitem
    select SUM(CANTIDAD) as ANULA_CONTADO  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'C' 
       AND B.MODULO = 'FARMACIA' AND TIPO_TRANSACCION IN ('IAN')  AND A.ESTADO  = 0 group by ITEM 
ENDTEXT
lejecuta=SQLEXEC(gconecta,lqry_ver_anulados_contado_c, "tanul_contado_c")
SELECT  tanul_contado_c
nc = RECCOUNT()
IF nc > 0 
  lnanulado_contado_c = tanul_contado_c.ANULA_CONTADO
ELSE
  lnanulado_contado_c = 0
ENDIF
lnanulado_contado_t  = lnanulado_contado_f + lnanulado_contado_c
 
  
 
 ****************************** FINAL DE CALCULAR LOS ANULADOS CONTADOS
 
 
 **** INICIO DE LOS ANULADOS CREDITO PACIENTES ***
 
TEXT TO lqry_ver_cp_anulados_f noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lcitem varchar(13) =  ?lcitem
  select SUM(CANTIDAD) as DEVO_CREDITO_PACIENTE    from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'F' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('IAN')  AND IDTRANSACCION = (select IDTRANSACCION  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'F' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('VRP'))  group by ITEM  
ENDTEXT
lejecuta=SQLEXEC(gconecta,lqry_ver_cp_anulados_f, "tanul_cp")
SELECT tanul_cp
ncp = RECCOUNT()
IF ncp > 0 
  lnanulado_cp_f = tanul_cp.DEVO_CREDITO_PACIENTE
ELSE
  lnanulado_cp_f = 0
ENDIF

 
TEXT TO lqry_ver_cp_anulados_c noshow
   declare @opeinicio varchar(8) = ?lcoperacioninicial
   declare @opefin varchar(8) = ?lcoperacionfinal
   declare @lcitem varchar(13) =  ?lcitem
  select SUM(CANTIDAD) as DEVO_CREDITO_PACIENTE    from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'C' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('IAN')  AND IDTRANSACCION = (select IDTRANSACCION  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'C' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('VRP'))  group by ITEM  
ENDTEXT
lejecuta=SQLEXEC(gconecta,lqry_ver_cp_anulados_c, "tanul_cp_c")
SELECT tanul_cp_c
ncp_c = RECCOUNT()
IF ncp_c > 0 
  lnanulado_cp_c = tanul_cp_c.DEVO_CREDITO_PACIENTE
ELSE
  lnanulado_cp_c = 0
ENDIF
lnanulado_cp_t =   lnanulado_cp_f +   lnanulado_cp_c

* ?lnsc  - ?lnanulado_contado_t
?lnsc
?lnanulado_contado_t
 TEXT TO lgrabar_pdiario noshow
   UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET  VENTAS_CONTADO = ?lnsc  - ?lnanulado_contado_t, CREDITO_PACIENTE = ?lncp - ?lnanulado_cp_t, SIS = ?lnsis, DOSIS_UNITARIA = ?lndosis_unitaria, TOTAL_SIS = ?lnsis + ?lndosis_unitaria, INTERVENCION_SANITARIA = ?lnintervencion_sanitaria - ?ling_devo,
      SOAT = ?lnsoat, EXONERADO = ?lnexonerado, TRANSFERENCIA_DEVOLUCIONES = ?lncanti_trans   where ITEM = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lgrabar_pdiario)
 


 TEXT TO limporte noshow
    update [SIGSALUD].[dbo].[TMP_PRE_ICI] set IMPORTE_VENTAS = VENTAS_CONTADO * PRECIO, DFECHA_FIN_PROCESO = GETDATE() 
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,limporte)
 
 *** farmacia ****
 TEXT TO lanula_sis noshow
  declare @opeinicio varchar(8) = ?lcoperacioninicial
  declare @opefin varchar(8) = ?lcoperacionfinal
  declare @lcitem varchar(13) = ?lcitem
  select SUM(CANTIDAD) as ANULA_SIS from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'F' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('IAN')  AND IDTRANSACCION = (select IDTRANSACCION  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'F' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('VRS'))  group by ITEM  
  ENDTEXT
 lejecuta=SQLEXEC(gconecta,lanula_sis, "tsis") 
 SELECT tsis
 ldevo_sis = tsis.anula_sis
  *** fin de farmacia  ****
   
 ***** Consultorios 
 TEXT TO lanula_sis_c noshow
  declare @opeinicio varchar(8) = ?lcoperacioninicial
  declare @opefin varchar(8) = ?lcoperacionfinal
  declare @lcitem varchar(13) = ?lcitem
  select SUM(CANTIDAD) as ANULA_SIS from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'C' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('IAN')  AND IDTRANSACCION = (select IDTRANSACCION  from [SIGSALUD].[dbo].[V_KARDEX] a left join USUARIO b on b.USUARIO = a.USUARIO  where OPERACION between @opeinicio and @opefin and ITEM = @lcitem  and ALMACEN = 'C' AND
   B.MODULO = 'FARMACIA'  AND TIPO_TRANSACCION IN ('VRS'))  group by ITEM  
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lanula_sis_c, "tsis_c") 
 SELECT tsis_c
 ldevo_sis_c = tsis_c.anula_sis
 ************************   fin de consultorios
 ltotal_restar_sis =   ldevo_sis + ldevo_sis_c
  



 text to lresta noshow
   UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET total_sis = total_sis - ?ltotal_restar_sis WHERE item = ?lcitem
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,lresta)
  
 cMensage = ' REVISANDO PARA ITEM : ' +lcnombre   + '... EL QUE NO TENGA PACIENCIA, NO LO EXIGA DE LOS DEMAS...' 
  _Screen.Scalemode = 0
 Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait

ENDSCAN

cMensage = ' ... LIMPIANDO STOCKS CON SALDO CERO ...' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait

TEXT TO leliminar NOSHOW  
  DELETE FROM [SIGSALUD].[dbo].[TMP_PRE_ICI] WHERE STOCK_TOTAL = 0 AND SALDO_MES_ANTERIOR = 0
ENDTEXT
lejecuta=SQLEXEC(gconecta,leliminar)

TEXT TO lagregar_user  NOSHOW  
	  UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET usuario = ?lcuser, fecha_inicial = ?lcfechainicio_mostrar, fecha_final = ?lcfechafin_mostrar, operacion_inicial = ?lcoperacioninicial, OPERACION_FINAL =  ?lcoperacionfinal
ENDTEXT
lejecuta=SQLEXEC(gconecta,lagregar_user)

 TEXT TO ltotal_salida noshow
    UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET TOTAL_SALIDA  = ventas_contado + credito_paciente + total_sis + intervencion_sanitaria + soat + exonerado 
     UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET SALDO_FINAL  = STOCK_TOTAL
 ENDTEXT
 lejecuta=SQLEXEC(gconecta,ltotal_salida)

TEXT TO llimpia_tbl  NOSHOW  
	  UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET sismed = '' WHERE sismed = '0'
ENDTEXT
lejecuta=SQLEXEC(gconecta,llimpia_tbl)


TEXT TO llimpia_tbl2  NOSHOW  
	  UPDATE [SIGSALUD].[dbo].[TMP_PRE_ICI] SET presentacion = '' WHERE presentacion = '0'
ENDTEXT
lejecuta=SQLEXEC(gconecta,llimpia_tbl2)

lcuser = "Jobeso"
lmin = lcoperacioninicial
lmax = lcoperacionfinal
lcfecharegistro1 = lcfechainicio_mostrar
lcfecharegistro2 = lcfechafin_mostrar

TEXT TO lver_final noshow
 SELECT * FROM [SIGSALUD].[dbo].[TMP_PRE_ICI] ORDER BY NOMBRE_CLASE, NOMBRE ASC
ENDTEXT
lejecuta=SQLEXEC(gconecta,lver_final, "tfin")
SELECT tfin
nfin = RECCOUNT()
IF nfin = 0
   MESSAGEBOX("NO EXISTEN REGISTROS EN ESTE RANGO DE OPERACIONES Y FECHAS ...",1, "GRACIAS POR SU PREFERENCIA.....")
   RETURN .T.
ELSE
  cMensage = ' ...ARCHIVO EN EXCEL: ARCHIVO_PRE_ICI_TOTAL.XLS....UBICADO EN LA UNIDAD : D.... PROCESO CULMINADO...VAMOS CON EL REPORTE......' 
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait
  COPY TO 'D:\ARCHIVO_PRE_ICI_TOTAL_INDIVIDUAL.XLS' TYPE XLS
  DO FOXYPREVIEWER.APP
  _Screen.oFoxyPreviewer.cLanguage = "SPANISH"
  REPORT FORM rpt_pre_ici.frx PREVIEW   
ENDIF








