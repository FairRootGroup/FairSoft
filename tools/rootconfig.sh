#!/bin/bash


   echo $arch

   if [ "$debug" = "yes" ];
   then
     if [ "$compiler" = "Clang" -a "$arch" = "linux" ]; then
       debugstring=""
     else
       debugstring="-DCMAKE_BUILD_TYPE=Debug"
     fi
   else
     debugstring=""
   fi   

   ########### Xrootd has problems with gcc4.3.0 and 4.3.1 
   ########### Roofit has problems with gcc3.3.5  
   XROOTD="-Dxrootd=ON"
   export XRDSYS=$SIMPATH_INSTALL
   ROOFIT="-Droofit=ON"
   if [ "$compiler" = "gcc" ]; then
     gcc_major_version=$(gcc -dumpversion | cut -c 1)
     gcc_minor_version=$(gcc -dumpversion | cut -c 3)
     gcc_sub_version=$(gcc -dumpversion | cut -c 5)

     if [ $gcc_major_version -eq 4 -a $gcc_minor_version -eq 3 ];
     then
       XROOTD="-Dxrootd=OFF"
     fi

     if [ $gcc_major_version -eq 3 -a $gcc_minor_version -eq 3 -a $gcc_sub_version -eq 5 ];
     then
       ROOFIT=" "
     fi

   fi

   if [ $isMacOsx108 ]; then
     XROOTD="-Dxrootd=OFF"
   fi
   #######################################################

   OPENGL=" "
   if [ "$compiler" = "Clang" ]; then
     root_comp_flag="-DCMAKE_C_COMPILER=clang -DCMAKE_CXXCOMPILER=clang"
     if [ $haslibcxx ]; then
       root_comp_flag="-DCMAKE_C_COMPILER=clang -DCMAKE_CXXCOMPILER=clang -Dcxx11=ON -Dlibcxx=ON"
     fi
     if [ "$platform" = "linux" ]; then
       OPENGL="-DOPENGL_INCLUDE_DIR=$SIMPATH_INSTALL/include -DOPENGL_gl_LIBRARY=$SIMPATH_INSTALL/lib"
     fi
   else
     root_comp_flag="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_LINKER=$CXX"   
   fi

   if [ "$build_python" = "yes" ];
   then
      PYTHONBUILD="-Dpython=ON"
   else   
      PYTHONBUILD=" "
   fi

   if [ "$arch" = "ppc64le" ];
   then
     VC="-Dvc=OFF"
   else
     VC="-Dvc=ON"
   fi

set -xv
   if [ "$platform" = "macosx" ]; then
     clang_version=$(clang --version | head -1 | cut -f 4 -d' ' | cut -f1,2 -d.)
     clang_major_version=$(echo $clang_version | cut -f1 -d.)
     if [ "$clang_version" = "7.3" -o $clang_major_version -ge 8 ]; then
       VC="-Dvc=OFF"
       XROOTD="-Dxrootd=OFF"
     fi
   fi
set +xv

   #######################################################
      
     etc_string="-DCMAKE_INSTALL_SYSCONFDIR=$SIMPATH_INSTALL/share/root/etc"
     prefix_string="-DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL"
 
     cmake ../ -Dsoversion=ON $PYTHONBUILD $XROOTD  $ROOFIT \
                    -Dminuit2=ON  -Dgdml=ON -Dxml=ON \
		    -Dbuiltin-ftgl=ON -Dbuiltin-glew=ON \
                    -Dbuiltin-freetype=ON $OPENGL \
                    -Dmysql=ON -Dpgsql=ON  -Dasimage=ON \
                    -DPYTHIA6_DIR=$SIMPATH_INSTALL \
                    -DPYTHIA8_DIR=$SIMPATH_INSTALL \
                    -Dglobus=OFF \
                    -Dreflex=OFF \
                    -Dcintex=OFF \
                    -Drpath=ON \
                    -Dmemstat=ON \
                     $VC \
                    -Dhttp=ON \
                    -DGSL_DIR=$SIMPATH_INSTALL \
                    -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_COMPILER=$CC \
                    -DCMAKE_F_COMPILER=$FC $root_comp_flag $prefix_string \
                    $etc_string -Dgnuinstall=ON \
                    -DCMAKE_BUILD_TYPE=$BUILD_TYPE

