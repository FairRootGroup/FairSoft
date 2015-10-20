#!/bin/bash

#author: Ahmed El Alaoui, USM

install_data=$SIMPATH_INSTALL/share/lhapdf/data

if [ ! -d  $install_data ];
then
  mkdir -p $install_data
  ln -s $install_data $SIMPATH_INSTALL/share/lhapdf/PDFsets
fi

cd $install_data

pdfset=("cteq6ll" "cteq66a" "cteq66a0" "cteq4m")

START=0
END=${#pdfset[@]}

for (( t=$START; t<$END; t++ )); do
  pdf=${pdfset[${t}]}
  if [ ! "$pdf" = "cteq66a" ]; then  
   if [ -f "$pdf.LHgrid" -o -f "$pdf.LHpdf" ];then
    echo $pdf already installed
   else
    tt=$($SIMPATH_INSTALL/bin/lhapdf-getdata $pdf --dest=$install_data)
    if [ "$tt" -eq "0" ]; then
      echo cannot find $pdf 
    fi
   fi
  fi 
done

cd $SIMPATH
return 1
