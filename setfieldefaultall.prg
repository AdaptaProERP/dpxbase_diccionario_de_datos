// Programa   : SETFIELDEFAULTALL
// Fecha/Hora : 03/02/2024 06:10:07
// Prop�sito  : Definicion para todas las Tablas
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("SETFIELDEFAULT","DPEMPRESA" ,"EMP_CODSAS",[&oDp:cCodSas])
  EJECUTAR("SETFIELDEFAULT","DPUSUARIOS","USU_CODSAS",[&oDp:cCodSas])

  IF oDp:cType="SGE"

    EJECUTAR("SETFIELDEFAULT","DPCTAEGRESO","CEG_CODCLA",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_ZONANL",["N"])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_PAIS"  ,[&oDp:cPais])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_ESTADO",[&oDp:cEstado])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_MUNICI",[&oDp:cMunicipio])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_PARROQ",[&oDp:cParroquia])

    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_ACTIVI",[&oDp:cActividad])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_CODCLA",[&oDp:cProClasifica])
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDOR","PRO_CODRMU",[&oDp:cCodRmu])

    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_ZONANL",["N"])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_CODRUT",[&oDp:cCodRuta])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_CODVEN",[&oDp:cCodVen])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_CODCLA",[&oDp:cCodCliCla])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_ACTIVI",[&oDp:cCodActEco])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_SITUAC",["A"])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTES"      ,"CLI_CONTRI",["S"])



    EJECUTAR("SETFIELDEFAULT","DPPROVEEDORPROG" ,"PGC_CTAEGR",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPCTAEGRESO"     ,"CEG_CODCLA",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPCTAEGRESO"     ,"CEG_TIPIVA",["EX"])

   
    EJECUTAR("SETFIELDEFAULT","DPDOCPROCTA"     ,"CCD_CODCTA",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPDOCPROCTA"     ,"CCD_CTAMOD",[&oDp:cCtaMod])
    EJECUTAR("SETFIELDEFAULT","DPDOCPROCTA"     ,"CCD_CTAEGR",[&oDp:cCtaIndef])

    EJECUTAR("SETFIELDEFAULT","DPDOCCLICTA"     ,"CCD_CTAMOD",[&oDp:cCtaMod])
    EJECUTAR("SETFIELDEFAULT","DPDOCCLICTA"     ,"CCD_CODCTA",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPDOCCLICTA"     ,"CCD_CTAEGR",[&oDp:cCtaIndef])
    EJECUTAR("SETFIELDEFAULT","DPDOCCLICTA"     ,"CCD_CENCOS",[&oDp:cCenCos])


    EJECUTAR("SETFIELDEFAULT","DPDOCCLI"        ,"DOC_CODMON",[&oDp:cMoneda])
    EJECUTAR("SETFIELDEFAULT","DPDOCCLI"        ,"DOC_CODTER","&oDp:cCodter")
    EJECUTAR("SETFIELDEFAULT","DPDOCCLI"        ,"DOC_CODMON","&oDp:cMoneda")
    EJECUTAR("SETFIELDEFAULT","DPDOCCLI"        ,"DOC_MTOCOM","0")

    EJECUTAR("SETFIELDEFAULT","DPDOCPRO"        ,"DOC_CODMON",[&oDp:cMoneda])

    EJECUTAR("SETFIELDEFAULT","DPCLIENTESREC","CRC_CODSUC",[&oDp:cSucursal])
    EJECUTAR("SETFIELDEFAULT","DPCLIENTESREC","CRC_CENCOS",[&oDp:cCenCos])

    EJECUTAR("SETFIELDEFAULT","DPINV"        ,"INV_APLICA",["T"])

    EJECUTAR("SETFIELDEFAULT","DPCAJAINS"      ,"ICJ_CODMON","&oDp:cMoneda")
    EJECUTAR("SETFIELDEFAULT","DPINV"          ,"INV_CODDEP","&oDp:cDepIndef")
    EJECUTAR("SETFIELDEFAULT","DPINV"          ,"INV_CODCAR","&oDp:cCodCar")

    EJECUTAR("SETFIELDEFAULT","DPMEMO"         ,"MEM_ID"    ,"&oDp:cIdMemo")
    EJECUTAR("SETFIELDEFAULT","DPCTA"          ,"CTA_CODMOD","&oDp:cCtaMod")
    EJECUTAR("SETFIELDEFAULT","DPCTAUSO"       ,"CUT_CTAMOD","&oDp:cCtaMod")
    EJECUTAR("SETFIELDEFAULT","DPLIBCOMPRASDET","LBC_CODMOD","&oDp:cCtaMod")
    EJECUTAR("SETFIELDEFAULT","DPCTAPRESUP"    ,"CPP_CTAMOD",[&oDp:cCtaMod])
    EJECUTAR("SETFIELDEFAULT","DPCTAPRESUP"    ,"CPP_CODCTA",[&oDp:cCtaIndef])



    EJECUTAR("SETFIELDEFAULT","DPMOVINV"   ,"MOV_PREDIV","0")           // evitar incidencias 
    EJECUTAR("SETFIELDEFAULT","DPMOVINV"   ,"MOV_LISTA",[&oDp:cLista])  // Lista por defecto



    EJECUTAR("SETFIELDEFAULT","DPGRUCARACT"   ,"GCR_CODMON","&oDp:cMonedaExt")

    EJECUTAR("SETFIELDEFAULT","DPPROVEEDORPROG","PGC_CTAMOD","&oDp:cCtaMod")
    EJECUTAR("SETFIELDEFAULT","DPPROVEEDORPROG","PGC_CODCTA","&oDp:cCtaIndef")

    EJECUTAR("SETFIELDEFAULT","DPACTIVOS","ATV_CENCOS","&oDp:cCenCos")

    EJECUTAR("SETFIELDEFAULT","DPGRU","GRU_CTAPRE","&oDp:cCtaPre")

    EJECUTAR("SETFIELDEFAULT","DPSERIEFISCAL","SFI_CODSUC","&oDp:cSucursal")


  ENDIF

RETURN .T.
// EOF


