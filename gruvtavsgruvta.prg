// Programa   : GRUVTAVSGRUVTA
// Fecha/Hora : 23/10/2023 03:47:10
// Propósito  :
// cCual  > Mayores
//        < Menores
//        = Iguales
//        0 No existe En P1 si en P2=no
//        1 Si Existe En P2 si en P1=No // LEFT JOIN 
// Query      :=https://github.com/AdaptaProERP/dpxbase_diccionario_de_datos/blob/main/VTAGRUVSVTAGRU.SQL
// Vista      :=https://github.com/AdaptaProERP/DPVISTAS/blob/main/DPGRUPO_VTA.SQL
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,dDesde1,dHasta1,dDesde2,dHasta2,cCual,cTable,cKey,cName,cField,cFieldF)
  LOCAL cSql,cWhere1,cWhere2,cSub,cIf:="",oTable,cHaving,aData:={}

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cWhere :="GRU_CODSUC"+GetWhere("=",cCodSuc),;
          dDesde1:=FchIniMes(oDp:dFecha-120),;
          dHasta1:=FchFinMes(dDesde1)   ,;
          dHasta2:=dDesde1-1            ,;
          dDesde2:=FchIniMes(dHasta2)   ,;
          cCual  :=">"                  ,;
          cTable :="view_dpgrupo_vta"   ,;
          cKey   :="GRU_CODIGO"         ,;
          cName  :="GRU_DESCRI"         ,;
          cField :="GRU_CANTID"         ,;
          cFieldF:="GRU_FECHA"

  cHaving:=[ HAVING ( VALDESDE>VALHASTA OR VALHASTA IS NULL) ]

/*
  IF "0"$cCual

    cWhere1:=GetWhereAnd("T1."+cFieldF,dDesde2,dHasta2)
    cWhere2:=GetWhereAnd("T2."+cFieldF,dDesde1,dHasta1)

    cHaving:=[ HAVING VALDESDE IS NULL ]

? cCual,cField," RETIRó DEBE INVERTIR LAS FECHA"

  ELSE
*/

    cWhere1:=GetWhereAnd("T1."+cFieldF,dDesde1,dHasta1)
    cWhere2:=GetWhereAnd("T2."+cFieldF,dDesde2,dHasta2)

//  ENDIF


  cSub:=[ @VALHASTA:=(SELECT SUM(]+cField+[) FROM ]+cTable+[ AS T2 ]+CRLF+;
        [  WHERE  T1.GRU_CODIGO=T2.]+cKey+[ AND ]+cWhere2+;
        [ ) AS VALHASTA, ]

  IF "FECHA"$cField

     cSub:=[ @VALHASTA:=(SELECT (DATEDIFF(MAX(]+cField+[), MIN(]+cField+[)) / (COUNT(]+cField+[) - 1) ]+;
           [) FROM ]+cTable+[ AS T2 ]+CRLF+;
           [  WHERE  T1.GRU_CODIGO=T2.]+cKey+[ AND ]+cWhere2+;
           [ ) AS VALHASTA, ]

// (SELECT (DATEDIFF(MAX(GRU_FECHA ), MIN(GRU_FECHA )) / (COUNT(GRU_FECHA ) - 1)))  AS VALDESDE,

  ENDIF


/*
  
  cIf :=[ IF (( SELECT SUM(]+cField+[) FROM ]+cTable+[ AS T2 ]+CRLF+;
        [  WHERE  T1.]+cField+[=T2.]+cKey+[ AND ]+cWhere2+[) IS NULL,SUM(]+cField+[), ]+CRLF+;
        [ ( SELECT SUM(]+cField+[) FROM ]+cTable+[ AS T2 ]+CRLF+;
        [  WHERE  T1.]+cKey+[=T2.]+cKey+[ AND ]+cWhere2+[)) AS DIF ]
*/


  

  // Retirar
  // IF "0"$cCual
  IF "<"$cCual
    cHaving:=[ HAVING ( VALDESDE<VALHASTA OR VALHASTA IS NULL) ]
  ENDIF

  // Debutar
  IF "1"$cCual
    cHaving:=[ HAVING VALHASTA IS NULL ]
  ENDIF

  cIf   :=[ SUM(]+cField+[)-IF(@VALHASTA IS NULL,0,@VALHASTA) AS VALDIF2 , 0 AS RATA ]



  IF "FECHA"$cField

    cIf   :=[ SUM(0)-IF(@VALHASTA IS NULL,0,@VALHASTA) AS VALDIF2 , 0 AS RATA ]


    cSql  :=[ SELECT  ]+CRLF+;
             cKey +[,]+CRLF+;
             cName+[,]+CRLF+;
            [ ]+cSub+CRLF+;
            [ (SELECT (DATEDIFF(MAX(]+cField+[), MIN(]+cField+[)) / (COUNT(]+cField+[) - 1))) ]+[ AS VALDESDE, ]+CRLF+;
            [ ]+cIf+CRLF+;
            [ FROM ]+cTable+[ AS T1 ]+CRLF+;
            [ WHERE ]+cWhere1  +CRLF+;
            [ GROUP BY ]+cKey  +CRLF+;
            cHaving+CRLF+;
            [ ORDER BY ]+cField+[ DESC ]

  ELSE

    cSql  :=[ SELECT  ]+CRLF+;
             cKey +[,]+CRLF+;
             cName+[,]+CRLF+;
            [ ]+cSub+CRLF+;
            [SUM(]+cField+[) AS VALDESDE, ]+CRLF+;
            [ ]+cIf+CRLF+;
            [ FROM ]+cTable+[ AS T1 ]+CRLF+;
            [ WHERE ]+cWhere1  +CRLF+;
            [ GROUP BY ]+cKey  +CRLF+;
            cHaving+CRLF+;
            [ ORDER BY ]+cField+[ DESC ]

  ENDIF

 IF "0"$cCual .OR. "="$cCual
    // Retirados

    cWhere1:=GetWhereAnd("T1."+cFieldF,dDesde2,dHasta2)
    cWhere2:=GetWhereAnd("T1."+cFieldF,dDesde1,dHasta1)

    cHaving:=[ HAVING VALANTERIOR>0 AND VALACTUAL=0 ]

    IF "="$cCual
       cHaving:=[ HAVING VALANTERIOR>0 AND (VALANTERIOR=VALACTUAL) ]
    ENDIF

    cSql  :=[ SELECT  ]+CRLF+;
           cKey +[,]+CRLF+;
           cName+[,]+CRLF+;
           [ SUM( CASE WHEN (]+cWhere1+[) THEN ]+cField+[ ELSE 0 END ) AS VALANTERIOR,]+;
           [ SUM( CASE WHEN (]+cWhere2+[) THEN ]+cField+[ ELSE 0 END ) AS VALANTERIOR,]+;
           [ SUM(IF(]+cWhere2+[,GRU_CANTID,0)) AS VALACTUAL,  ]+;
           [ 0 AS CERO,0 AS RATA ]+;
           [ FROM VIEW_DPGRUPO_VTA AS T1 ]+;
           [ WHERE 1=1 ]+;
           [ GROUP BY ]+cKey  +CRLF+;
           cHaving+;
           [ ORDER BY ]+cField+[ DESC ]

  ENDIF

  aData:=ASQL(cSql)

//  oTable:=OpenTable(cSql,.T.)
//  oTable:Browse()
//  oTable:End()
// ViewArray(aData)
//  aData:=oTable:aDataFill

  AEVAL(aData,{|a,n| aData[n,6]:=RATA(a[4],a[3])})

  IF "FECHA"$cField
    ADEPURA(aData,{|a,n| Empty(a[3]+a[4])})
    AEVAL(aData,{|a,n| aData[n,5]:=a[4]-a[3]})
  ENDIF

  oDp:cSql:=cSql

  aData:=ASORT(aData,,, { |x, y| x[6] > y[6] })


// ? CLPCOPY(oDp:cSql)

RETURN aData
// EOF
