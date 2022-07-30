* REPORTE CONSOLIDADO DE PRODUCCION ASISTENCIAL EN CONSULTA AMBULATORIA

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
      ?lcStringCnxLocal
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF



lc_fecha1 = '2017-09-01'
lc_fecha2 = '2017-09-30'
lcipress = '00005947'
lcmes = '09' 
lcanio = '2017'
* lcnombre_archivo + '.XLS'
lcnombre_archivo = 'D:\' + lcipress + '_' + lcmes + '_' + lcanio + '_' + 'TAB1.XLS'
lcnombre_archivotxt = 'D:\' + lcipress + '_' + lcmes + '_' + lcanio + '_' + 'TAB1.TXT'
TEXT TO lqry_uni NOSHOW
  declare @lcfecha1 datetime = convert(datetime, ?lc_fecha1, 101)
  declare @lcfecha2 datetime = convert(datetime, ?lc_fecha2, 101)
  declare @lcanio_mes varchar(6) = (select substring(convert(varchar(10), @lcfecha1, 103),7,4)) + (select substring(convert(varchar(10), @lcfecha1, 103),4,2))
  declare @lccodigo_ipress varchar(8) = '00005947'
  SELECT RTRIM(@lcanio_mes) as PERIODO, @lccodigo_ipress as IPRESS, @lccodigo_ipress as UGIPRESS, SEX as SEXO_PACIENTE, GRUPO_EDAD, atm as ATENCION_MEDICA, ATNM AS ATENCION_NO_MEDICA, ATTM AS ATENCION_POR_MES FROM [SIGSALUD].[dbo].[TMP_TR_ATEN_M]
  UNION ALL
  SELECT RTRIM(@lcanio_mes) as PERIODO, @lccodigo_ipress as IPRESS, @lccodigo_ipress as UGIPRESS, SEX as SEXO_PACIENTE, GRUPO_EDAD, atm as ATENCION_MEDICA, ATNM AS ATENCION_NO_MEDICA, ATTM AS ATENCION_POR_MES FROM [SIGSALUD].[dbo].[TMP_TR_ATEN_F]
ENDTEXT
lejecuta=SQLEXEC(gconecta,lqry_uni, "tunir_trama1") 
SELECT tunir_trama1   
lcnombre_archivotxt = 'D:\' + lcipress + '_' + lcmes + '_' + lcanio + '_' + 'TAB1.TXT'
COPY TO &lcnombre_archivo  TYPE XLS
GO top
Set alternate to &lcnombre_archivotxt
set alternate on 
SCAN
??ALLTRIM(tunir_trama1.periodo)+"�"+ALLTRIM(tunir_trama1.ipress)+"�"+ALLTRIM(tunir_trama1.ugipress)+"�"+ALLTRIM(tunir_trama1.sexo_paciente)+"�"+ALLTRIM(tunir_trama1.grupo_edad)+"�"+ALLTRIM(STR(tunir_trama1.atencion_medica))+"�"+ALLTRIM(STR(tunir_trama1.atencion_no_medica))+"�"+STRTRAN(ALLTRIM(str(tunir_trama1.atencion_por_mes)), ' ', '')+""
?
ENDSCAN
set alternate off 

cMensage = '...FINALIZADO...' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait    
CLOSE DATABASES all






