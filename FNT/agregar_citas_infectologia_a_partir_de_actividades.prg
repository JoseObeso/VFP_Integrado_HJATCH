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

** OBTENIENDO DATOS DE LAS ACTIVIDADES *

TEXT TO lqry_ver_fechas_actividades noshow
	TRUNCATE TABLE [SIGSALUD].[dbo].[TMP_DIAS_TURNO]
	declare @lcconsultorio varchar(6) = '1095' 
	declare @lcmedico varchar(3) = 'CAK'
	declare @lnmes int = 12
	declare @lnanio int = 2017
	declare @lcperiodo varchar(6) = convert(varchar(4), @lnanio) + convert(varchar(2), @lnmes) 
	declare @lc_servicio varchar(2) = '10'
	declare @lc_codigo varchar(13) = (SELECT CODIGO FROM [BDPERSONAL].[dbo].[MAESTRO] WHERE DNI_ACTUAL IN (select DNI from [SIGSALUD].[dbo].[MEDICO] where MEDICO = @lcmedico))
	declare @ln_actividad int = 4
	INSERT INTO [SIGSALUD].[dbo].[TMP_DIAS_TURNO]([DIA],[FECHA],[TURNO],[HORAS])
	select ('DIA' + RIGHT('00' + Ltrim(Rtrim(CONVERT(VARCHAR(2), DIA))),2) ) AS DIA, CONVERT(DATETIME, (CONVERT(VARCHAR(4), ANIO)  + '-' + CONVERT(VARCHAR(2), MES) + '-' + CONVERT(VARCHAR(2), DIA)), 101) AS FECHA, TURNO, HORAS  
	from [BDPERSONAL].[dbo].[ACTIVIDAD_DETALLE] where CODIGO = @lc_codigo and ANIO =  @lnanio and MES = @lnmes and ID_ACTIVIDAD = @ln_actividad
	order by CONVERT(int, dia)
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_ver_fechas_actividades)

TEXT TO ldia1 noshow
   SELECT DIA, TURNO, SUBSTRING(TURNO, 1,1) AS TURNO_1, SUBSTRING(TURNO, 2,1) AS TURNO_2 FROM [SIGSALUD].[dbo].[TMP_DIAS_TURNO] WHERE DIA = 'DIA01'
ENDTEXT
lejecutabusca = sqlexec(gconecta,ldia1, "tdia1")  
SELECT tdia1
* lndia





