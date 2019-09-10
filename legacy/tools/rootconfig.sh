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

   XROOTD="-Dxrootd=OFF -Dbuiltin_xrootd=ON"
   ROOFIT="-Droofit=ON"

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
      PYTHONBUILD="-Dpython=OFF"
   fi

   if [ "$arch" = "ppc64le" ];
   then
     VC="-Dvc=OFF"
   else
     VC="-Dvc=ON"
   fi

   #######################################################

     etc_string="-DCMAKE_INSTALL_SYSCONFDIR=share/root/etc"
     inc_string="-DCMAKE_INSTALL_INCLUDEDIR=include/root6"
     prefix_string="-DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL"

     cmake ../ -Dsoversion=ON $PYTHONBUILD $XROOTD  $ROOFIT \
                    -Dminuit2=ON  -Dgdml=ON -Dxml=ON \
                    -Dbuiltin-ftgl=ON -Dbuiltin-glew=ON \
                    -Dbuiltin-freetype=ON -Dbuiltin_gsl=ON  $OPENGL \
                    -Dasimage=ON \
                    -DPYTHIA6_DIR=$SIMPATH_INSTALL \
                    -DPYTHIA8_DIR=$SIMPATH_INSTALL \
                    -Dglobus=OFF \
                    -Dreflex=OFF \
                    -Dcintex=OFF \
                    -Drpath=ON \
                    -Dmemstat=ON \
                    -Ddavix=OFF \
                     $VC \
                    -Dhttp=ON \
                    -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_COMPILER=$CC \
                    -DCMAKE_F_COMPILER=$FC $root_comp_flag -Dgnuinstall=ON \
                    $prefix_string $inc_string  $etc_string \
                    -DCMAKE_BUILD_TYPE=$BUILD_TYPE
