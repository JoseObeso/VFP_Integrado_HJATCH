CLEAR
lc_fecha = '15/08/2022'

LnDatoEnviarD=((Dow(DATE() + 5))) 
?LnDatoEnviarD
LcDatoEnviarD=alltrim(str(day(DATE())))
?LnDatoEnviarD
LcDatoEnviarD=ICASE(LnDatoEnviarD=2,LcDatoEnviarD+'-:-'+'(Lunes)',LnDatoEnviarD=3,LcDatoEnviarD+'-:-'+'(Martes)',LnDatoEnviarD=4,LcDatoEnviarD+'-:-'+'(M�rcoles)',;
LnDatoEnviarD=5,LcDatoEnviarD+'-:-'+'(Jueves)',LnDatoEnviarD=6,LcDatoEnviarD+'-:-'+'(Viernes)',LnDatoEnviarD=7,LcDatoEnviarD+'-:-'+'(Sabado)',LnDatoEnviarD=1,LcDatoEnviarD+'-:-'+'(Domingo)')

?LcDatoEnviarD

