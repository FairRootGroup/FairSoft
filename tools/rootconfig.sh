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
   
     
   #######################################################
      
     etc_string="-DCMAKE_INSTALL_SYSCONFDIR=$SIMPATH_INSTALL/share/root/etc"
     prefix_string="-DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL"
     if [ $PYTHON_LIBRARY == "default" ];
      then
       non_default_python_loc=""
      else   
       non_default_python_loc="-DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR -DPYTHON_LIBRARY=$PYTHON_LIBRARY -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE"
     fi
     cmake ../ -Dsoversion=ON $PYTHONBUILD $XROOTD  $ROOFIT \
                     $non_default_python_loc \
                    -Dminuit2=ON  -Dgdml=ON -Dxml=ON \
		    -Dbuiltin-ftgl=ON -Dbuiltin-glew=ON \
                    -Dbuiltin-freetype=ON $OPENGL \
                    -Dmysql=ON -Dpgsql=ON  -Dasimage=ON \
                    -DPYTHIA6_DIR=$SIMPATH_INSTALL \
                    -DPYTHIA8_DIR=$SIMPATH_INSTALL \
                    -Dglobus=OFF \
                    -Dreflex=OFF \
                    -Dcintex=OFF \
                    -Dvc=ON -Dhttp=ON \
                    -DGSL_DIR=$SIMPATH_INSTALL \
                    -DCMAKE_BUILD_TYPE=Optimized \
                    -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_COMPILER=$CC \
                    -DCMAKE_F_COMPILER=$FC $root_comp_flag $prefix_string \
                    -DCMAKE_INSTALL_MACRODIR=$SIMPATH_INSTALL/share/root/macros \
                    -DCMAKE_INSTALL_ICONDIR=$SIMPATH_INSTALL/share/root/icons \
                    -DCMAKE_INSTALL_FONTDIR=$SIMPATH_INSTALL/share/root/fonts \
                    -DCMAKE_INSTALL_CMAKEDIR=$SIMPATH_INSTALL/share/root/cmake \
                    -DCMAKE_INSTALL_INCLUDEDIR=$SIMPATH_INSTALL/include/root \
                    -DCMAKE_INSTALL_LIBDIR=$SIMPATH_INSTALL/lib/root \
                    -DCMAKE_INSTALL_BINDIR=$SIMPATH_INSTALL/bin \
                    $etc_string -Dgnuinstall=ON $debugstring

