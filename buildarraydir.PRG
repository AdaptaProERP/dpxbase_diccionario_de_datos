// Programa   : BUILDARRAYDIR
// Fecha/Hora : 19/07/2023 07:30:39
// Prop�sito  : Convierte en Arreglo Direcci�n
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDir,nLen,nArray)
  LOCAL aDir:=ARRAY(0)
  LOCAL aText:={},nContar:=0,nLine:=1
  
  DEFAULT nLen  :=40,;
          nArray:=4 ,;
          cDir:="AV. LIBERTADOR, C.C. LIBERTADOR LOCAL 3A, ZONA INDUSTRIAL I"

  aDir :=ARRAY(nArray)
  aText:=_VECTOR(cDir," ")
  AEVAL(aDir,{|a,n| aDir[n]:=""})

  AEVAL(aText,{|a,n| aText[n]:={a,LEN(a)}})

  WHILE nContar<LEN(aText)
  
    IF LEN(aDir[nLine])+aText[nContar+1,2]<nLen
      aDir[nLine]:=aDir[nLine]+aText[nContar+1,1]+" "
    ELSE
      nLine++
    ENDIF

    nContar++

  ENDDO

  // VIEWARRAY(aDir)
  
RETURN aDir
// EOF
