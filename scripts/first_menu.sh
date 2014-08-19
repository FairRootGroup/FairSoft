#!/bin/bash

clear
echo
echo "What kind of installation you would like to do?"
PS3='Please enter a choice from the above menu: '

select CHOICE in "Custom installation (You will choose more options later)" "Automatic (debug no optimization no python binding no Data for G4)" "Grid (NO Graphics)" "Reconstruction only (NO Simulation no event generators)"   Quit
do
  case "$CHOICE" in
               Quit) exit
                     ;;
               "Automatic (debug no optimization no python binding no Data for G4)")
                     installation_type=automatic
                     break
                     ;;
               "Grid (NO Graphics)")
                     installation_type=grid
                     break
                     ;;
               "Reconstruction only (NO Simulation no event generators)")
                     installation_type=onlyreco
                     break
                     ;;
               "Custom installation (You will choose more options later)")
                     installation_type=custom
                     break
                     ;;
                "")
                     echo This value is not valid. Hit Enter to see menu again!
                     continue
                     ;;
   esac
done

