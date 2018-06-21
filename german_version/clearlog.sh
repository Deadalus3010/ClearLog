##############################################
##  !/bin/bash
## __     __   __     ______   ______    
##/\ \   /\ "-.\ \   /\  ___\ /\  __ \   
##\ \ \  \ \ \-.  \  \ \  __\ \ \ \/\ \  
## \ \_\  \ \_\\"\_\  \ \_\    \ \_____\ 
##  \/_/   \/_/ \/_/   \/_/     \/_____/ 
##
##  - Pr�ft Dateialter
##  - Wenn Maxalter �berschritten, 
##    L�schung des Dateiinhaltes
##  - Erstellt logs was er tut
##
##  Script von:
##  https://github.com/Deadalus3010
##
##  comparedate() von ashrithr:
##  https://gist.github.com/ashrithr/5614283
##
##  displaytime() von St�phane Gimenez:
##  https://unix.stackexchange.com/users/9426/st%c3%a9phane-gimenez
##  https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
##
##############################################

clearlogascii() {
cat << EOT
   _____ _                 _                 
  / ____| |               | |                
 | |    | | ___  __ _ _ __| |     ___   __ _ 
 | |    | |/ _ \/ _' | '__| |    / _ \ / _' |
 | |____| |  __/ (_| | |  | |___| (_) | (_| |
  \_____|_|\___|\__,_|_|  |______\___/ \__, |
                                        __/ |
                                       |___/
EOT
}
clearlogascii

##############################################
##
##
## Inkludieren der logclear.config und logclear.lang
MYDIR=$(dirname $(readlink -f $0))
##
. "$MYDIR"/clearlog.config
. "$MYDIR"/clearlog.lang     
##
## 
##############################################
#
#           __         ____             __ 
#     _____/ /_       / __ )____ ______/ /_
#    / ___/ __ \     / __  / __ `/ ___/ __ \
# _ (__  ) / / /    / /_/ / /_/ (__  ) / / /
#(_)____/_/ /_/    /_____/\__,_/____/_/ /_/
#               
#
################BEGIN TOOLBOX#################

#funtion arguments -> filename to compare against curr time
function comparedate() {
if [ ! -f $1 ]
then

   echo -e "${LANG_COMPAREDATECHECK}\n"
	   exit 1

fi

#MAXAGE=$(bc <<< '60')
#Dateialter in Sekunden = current_time - file_modification_time.
FILEAGE=$(($(date +%s) - $(stat -c '%Y' "$1")))
test $FILEAGE -lt $MAXAGE && {
    #Weniger als 60 Sekunden
    return 0
}
#Mehr als 60 Sekunden
return 1
}

#Wenn es mehr als 60 Sekunden sein sollten.
#Rechnet Sekunden automatisch in STUNDEN // MINUTEN // SEKUNDEN Format um.
#Wichtig f�rs Datum.

function displaytime() {

  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))

  (( $D > 0 )) && printf "%d $DATEOUTPUTD " $D
  (( $H > 0 )) && printf "%d $DATEOUTPUTH " $H
  (( $M > 0 )) && printf "%d $DATEOUTPUTM " $M

  (( $D > 0 || $H > 0 || $M > 0 )) && printf "und "

  printf "%d $DATEOUTPUTS\n" $S

}

##################END TOOLBOX#################

#Damit der Text in der Console 1 Zeile nach unten rutscht
echo -e "\n"

#Pr�ft, ob wir Logs vom Script erlauben
if [ $LOGALLOW -eq 1 ]
then
   #Pr�ft, ob clearlog.log da ist
   for i in $LOGPATH$LOGFILE
   do
       echo ${LANG_CHECKLOGFILE}
       if [ -f $i ]
       then

           echo -e ${LANG_LOGFILEFOUND}

       else

           echo -e ${LANG_LOGFILENOTFOUND}
           touch $LOGPATH$LOGFILE

	   if [ ! -f $i ]
           then

	         echo ${LANG_LOGFILECREATEERROR}

	   fi

           #Einmaliges ausschreiben des Ascii Logos in die Script Log Datei
	   clearlogascii >> "$LOGPATH""$LOGFILE"
           #Schreibt den erstellten Pfad f�r die Script Logs in das Script Log.
	   echo "<"$FILEDATE"> "$LOGPATH""$LOGFILE" ${LANG_LOGFILEPATHCREATE}" >> "$LOGPATH""$LOGFILE"

        fi
   done
fi

#Pr�ft, ob wir das Bewegen von alten bereits bearbeiteten veralteten Logs erlauben
if [ $CLEARMOVEFILEALLOW -eq 1 ]
then
   #Pr�ft, ob der Ordner da ist
   for i in $CLEARMOVEPATH$CLEARMOVEDIRECTORY
   do
       echo ${LANG_CHECKMOVEFOLDER}
       if [ -d $i ]
       then

           echo ${LANG_MOVEFOLDERFOUND}

       else

           echo -e ${LANG_MOVEFOLDERNOTFOUND}
           mkdir $CLEARMOVEPATH$CLEARMOVEDIRECTORY

	   if [ ! -d $i ]
           then
	         echo ${LANG_MOVEFOLDERCREATEERROR}
	   fi

           #Pr�ft, ob wir Logs vom Script erlauben
           if [ $LOGALLOW -eq 1 ]
           then
	
	      #Schreibt den erstellten Pfad f�r die alten Logs in das Script Log.
	      echo "<"$FILEDATE"> "$CLEARMOVEPATH""$CLEARMOVEDIRECTORY" ${LANG_MOVEFOLDERCREATE}" >> "$LOGPATH""$LOGFILE"
	
           fi


        fi
   done
fi

   if [ ! -f $CLEARPATH$CLEARNAME ]
   then

      echo -e "${LANG_FILEDONTEXISTS}\n"
      FILECOUNT=0

   else

      #Z�hlt, wie viele Dateien im Ordner sind (F�r Consolen Ausgabe + Script Log)
      FILECOUNT=`find $CLEARPATH$CLEARNAME -type f | wc -l`

   fi

   #Debug und loggen der Dateianzahl im Ordner und des angegebenen Maxalters. Erlauben wir Logs? Bewegen der alten Logs? L�schen?
   echo -e ""$FILECOUNT" ${LANG_DEBUG}"

   #Erlauben wir Logs vom Script?
   if [ $LOGALLOW -eq 1 ]
   then

   #Debug und loggen der Dateianzahl im Ordner und des angegebenen Maxalters in der Script Log Datei. Erlauben wir Logs? Bewegen der alten Logs? L�schen?
   echo -e "\n"$FILECOUNT" ${LANG_DEBUG}" >> "$LOGPATH""$LOGFILE"

   fi

   #Checke Alter Ausgabe f�r Debug (Nur Console)
   echo -e "\n...${LANG_CHECKAGE}...\n"

   #Variablen Deklaration fuer Dateiz�hler (Nur Console)
   LFNR=1

#Ruft jede Datei einzeln auf, die mit CLEARNAME anfangen.
#L�uft solange, bis es keine CLEARNAME Datei mehr findet. 
#Filename ist der Name, den die funktion gerade eingelesen hat
for FILENAME in $CLEARPATH$CLEARNAME
do

   #Anzahl der gerade zu bearbeitende Datei ausgeben (Nur Console)
   #Incrementieren des Dateiz�hler
   echo ""$LFNR". ${LANG_FILENAME}"
   let LFNR=$LFNR+1

   #Aufrufen der Funktion um das Alter der Log Dateien zu ermitteln.
   comparedate $FILENAME
   AGE="$?"

   #Consolen Output
   echo -e "${LANG_FILENAME}: "$FILENAME" \t${LANG_CLEARCHECK}"

   #If-Methode, die den R�ckgabewert des Alters ueberprueft
   if [ "$AGE" -eq 1 ]
   then 

	#Consolen Output
	echo -e "<"$FILEDATE"> ${LANG_FILENAME} ${LANG_CLEARWRITE}, ${LANG_FILEAGE}: "$(displaytime $FILEAGE)".\n"

	#Ueberschreiben des Dateiinhaltes
	echo -e "<"$FILEDATE"> - $FILENAME ${LANG_CLEARDELETE} ${LANG_FILENAME} "$(displaytime $FILEAGE)" ${LANG_FILEAGE3}. \n\t\t\t\t\t"$(displaytime MAXAGE)" ${LANG_MAXAGEEXCEEDED}." > "$FILENAME"
	
	#Erlauben wir das die alten Logs bewegt werden?
	if [ $CLEARMOVEFILEALLOW -eq 1 ]
	then

           #Moved die Datei in den Ordner
           echo -e "Bewege: "$FILENAME" - ${LANG_MOVETO} - \n"$CLEARMOVEPATH""$CLEARMOVEDIRECTORY". \n"
	   mv $FILENAME $CLEARMOVEPATH$CLEARMOVEDIRECTORY

	fi

         #Erlauben wir das L�schen der alten Logs?
	 if [ $CLEARLOGDELETEALLOW -eq 1 ]
	 then
	    
            #Z�hlt, wie viele Dateien im Ordner sind (F�r Script + Script Log)
            FILECOUNTDELETE=`find $CLEARLOGDELETEPATH$CLEARLOGDELETENAME -type f | wc -l`

            #Pr�ft, ob man Dateilimit zum L�schen der Logs auf 1 gesetzt hat.
            if [ $CLEARLOGDELETEFILECOUNT -eq 1 ]
            then

               #L�schen der alten Logs
               rm $CLEARLOGDELETEPATH$FILENAME

               #Pr�ft, ob die Datei noch im Ordner ist
               if [ -f $FILENAME ]
               then

	          echo -e ${LANG_DELETEWASUNSUCCESSFUL}

	          #Erlauben wir Logs vom Script?
	          if [ $LOGALLOW -eq 1 ]
	          then

	            #Schreibt Datei L�schdatum ganz unten in die Script Log Datei
	            echo -e "\n${LANG_DELETEWASUNSUCCESSFUL}." >> "$LOGPATH""$LOGFILE"
	
	         fi

               else

                  echo -e ${LANG_DELETEWASSUCCESSFUL}

	          #Erlauben wir Logs vom Script?
	          if [ $LOGALLOW -eq 1 ]
	          then

	            #Schreibt Datei L�schdatum ganz unten in die Script Log Datei
	            echo -e "\n<"$FILEDATE"> '"$FILENAME"' ${LANG_CLEARDELETE2}." >> "$LOGPATH""$LOGFILE"
	
	          fi

            fi

            #Pr�ft, ob Dateianzahl dem Dateilimit entspricht
            elif [ $FILECOUNTDELETE -eq $CLEARLOGDELETEFILECOUNT ]
            then

               for FILENAME in $CLEARLOGDELETEPATH$CLEARLOGDELETENAME
               do                  

                  #L�scht die gerade gefundene Log Datei
                  rm $FILENAME 
                  echo ${LANG_DELETEWASSUCCESSFUL}

                  if [ -f $FILENAME ]
                  then  

	             echo -e ${LANG_DELETEWASUNSUCCESSFUL}

	             #Erlauben wir Logs vom Script?
	             if [ $LOGALLOW -eq 1 ]
	             then

	               #Schreibt Datei L�schdatum ganz unten in die Script Log Datei
	               echo -e "\n${LANG_DELETEWASUNSUCCESSFUL}." >> "$LOGPATH""$LOGFILE"
	
	            fi


                  else 

                     #Unn�tig, da wir oben das gleiche in die Console schreiben
                     #echo -e ${LANG_DELETEWASSUCCESSFUL}

	             #Erlauben wir Logs vom Script?
	             if [ $LOGALLOW -eq 1 ]
	             then

	               #Schreibt Datei L�schdatum ganz unten in die Script Log Datei
	               echo -e "\n<"$FILEDATE"> '"$FILENAME"' ${LANG_CLEARDELETE2}." >> "$LOGPATH""$LOGFILE"
	
	             fi


                  fi

               done

            #Ausgabe wenn er nichts gemacht hat
            else

               echo -e ${LANG_DELETENOTHING}
	
            fi
	 fi



	#Erlauben wir Logs vom Script?
	if [ $LOGALLOW -eq 1 ]
	then

	   #Schreibt Datei Pr�fdatum ganz unten in die Script Log Datei
	   echo -e "\n<"$FILEDATE"> '"$FILENAME"' ${LANG_WASCLEARED}, ${LANG_FILENAME} "$(displaytime $FILEAGE)" ${LANG_FILEAGE2}." >> "$LOGPATH""$LOGFILE"
	
           #Erlauben wir das alte Logs bewegt werden?
	   if [ $CLEARMOVEFILEALLOW -eq 1 ]
	   then

	      #Schreibt Datei Movedatum ganz unten in die Script Log Datei
	      echo -e "\n<"$FILEDATE"> '"$FILENAME"' ${LANG_MOVEACTIVITY} $CLEARMOVEPATH$CLEARMOVEDIRECTORY ${LANG_MOVEACTIVITY2}." >> "$LOGPATH""$LOGFILE"
	
	   fi

	fi

   else

	#Consolen Output
	echo -e "<"$FILEDATE"> ${LANG_FILENAME} ${LANG_WASNOTCLEARED}, ${LANG_FILENAME} "$(displaytime $FILEAGE)" "${LANG_FILEAGE2}".\n"

	#Erlauben wir Logs vom Script?
	if [ $LOGALLOW -eq 1 ]
	then
	
	   #Schreibt Datei Pr�fdatum ganz unten in die Script Log Datei
	   echo -e "\n<"$FILEDATE"> '"$FILENAME"' ${LANG_CHECKFILEAGE}, ${LANG_FILEAGE} "$(displaytime $FILEAGE)". - "$(displaytime $MAXAGE)" ${LANG_MAXAGE}." >> "$LOGPATH""$LOGFILE"
	
	fi

   fi
done