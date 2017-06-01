# meny

echo "1. Vis data om ansatt
2. Registrer ny ansatt
3. Endre ansatt
4. Slette ansatt
0. Avslutt"

# Passord
katt=$(grep "tmp logg" ~/script/passord | cut -d":" -f2)

valg2=1
while

	(( $valg2 > 0 ))
	do 
	read -p "Valg: " valg2
	
	case "$valg2" in
		
		0) exit
		;;
		1) read -p "Vis data om ansatt nr: " ansatt_id
			mysql -u root -p$katt -Bse "USE personal;SELECT * FROM ansatte WHERE ansatt_id = $ansatt_id">edit.tmp
			fornavn=$(cut edit.tmp -f1)
			etternavn=$(cut edit.tmp -f2)
			epost=$(cut edit.tmp -f3)
			gateadr=$(cut edit.tmp -f4)
			postnr=$(cut edit.tmp -f5)
			sted=$(cut edit.tmp -f6)
			tlf=$(cut edit.tmp -f7)
			f_dato=$(cut edit.tmp -f8)

			#konvertering av dato (inn)
			d=$(echo $f_dato | cut -d"-" -f3)
			m=$(echo $f_dato | cut -d"-" -f2)
			y=$(echo $f_dato | cut -d"-" -f1)
			#konvertering slutt

			avd=$(cut edit.tmp -f10)

			echo "
-----------------------------------------
|     Eksisterende info i database      |"
			echo "#########################################
1. Fornavn: $fornavn
2. Etternavn: $etternavn
3. Epost: $epost
4. Gateadresse: $gateadr
5. Postnr: $postnr
6. Sted: $sted
7. Telefon: $tlf
8. Fødselsdato (DD-MM-YYYY): $d-$m-$y
9. Avd: $avd
0. Lagre i database og avslutt
-----------------------------------------   
|          Avbryt med CTRL-C            |"
			echo "#########################################"
		
			rm ~/script/sql/edit.tmp
		;;
		2) # MySQL ny ansatt

			# Registrering av data
			read -p "Fornavn: " fornavn
			read -p "Etternavn: " etternavn
			read -p "Epost-adresse: " email
			read -p "Gateadresse: " gateadr

			# sjekk at postnr er tall
			err1=1

			while (( $err1 > 0 )); do
			read -p "Postnummer (4 siffer): " postnr
			err1=0
				case $postnr in
					''|*[!0-9]*) err1=1 ;;
					*) if [ ${#postnr} != 4 ]; then err1=2 ;
						  else err1=0
					   fi ;;
				esac
			done
			# postnr slutt

			sted=$(mysql -u root -ppetunia -Bse "USE personal;SELECT * FROM postnr WHERE postnr = $postnr")

			#sjekk at tlfnr er 8 siffer
			err1=1

			while (( $err1 > 0 )); do
			read -p "Telefonnummer (8 siffer): " telefon
			err1=0
				case $telefon in
					''|*[!0-9]*) err1=1 ;;
					*) if [ ${#telefon} != 8 ]; then err1=2 ;
						  else err1=0
					   fi ;;
				esac
			done
			# tlfnr slutt

			read -p "Fødselsdato (DD-MM-YYYY): " f_dato
			read -p "Avdelingsnr: " avd_nr
						if [ $avd_nr= ]; then
							avd_nr="NULL"
						fi
			
			
			# Konvertering av dato
			konv_dato=$(mysql -u root -p$katt -Bse "SELECT STR_TO_DATE('$f_dato', '%d-%m-%Y')")

			
			# MySQL
			mysql -u root -p$katt -Bse "USE personal;INSERT INTO ansatte VALUE('$fornavn', '$etternavn', '$email', '$gateadr', $postnr, '$sted', $telefon, '$konv_dato', NOW(), $avd_nr, NULL);" &>>~/script/error.log

			# errorlog
			if [ $? > 0 ]; then
				echo -e "\n\033[0;31mNoe gikk galt!\033[0m Se error.log\n"
			fi	
		;;
		3) echo "Hvem vil du endre på i dag?"
			read -p "Ansatt ID: " ansatt

			# SQL
			mysql -u root -p$katt -Bse "USE personal;SELECT * FROM ansatte WHERE ansatt_id = $ansatt">edit.tmp

			fornavn=$(cut edit.tmp -f1)
			etternavn=$(cut edit.tmp -f2)
			epost=$(cut edit.tmp -f3)
			gateadr=$(cut edit.tmp -f4)
			postnr=$(cut edit.tmp -f5)
			sted=$(cut edit.tmp -f6)
			tlf=$(cut edit.tmp -f7)
			f_dato=$(cut edit.tmp -f8)

			#konvertering av dato (inn)
			d=$(echo $f_dato | cut -d"-" -f3)
			m=$(echo $f_dato | cut -d"-" -f2)
			y=$(echo $f_dato | cut -d"-" -f1)
			#konvertering slutt

			avd=$(cut edit.tmp -f10)


			echo "
-----------------------------------------
Eksisterende info i database"
echo "#########################################
1. Fornavn: $fornavn
2. Etternavn: $etternavn
3. Epost: $epost
4. Gateadresse: $gateadr
5. Postnr: $postnr
6. Sted: $sted
7. Telefon: $tlf
8. Fødselsdato (DD-MM-YYYY): $d-$m-$y
9. Avd: $avd
0. Lagre i database og avslutt
-----------------------------------------   
   Avbryt med CTRL-C"
			echo "#########################################"


			# Oppretter variabler på det som skal endres
			ny_fornavn="1048576"
			ny_etternavn="1048576"
			ny_epost="1048576"
			ny_gateadr="1048576"
			ny_postnr="1048576"
			ny_sted="1048576"
			ny_tlf="1048576"
			ny_f_dato="1048576"
			ny_avd="1048576"


			# Brukers input (loop/case)
			valg=1
			while

				(( $valg > 0 ))
				do 
				read -p "Valg: " valg

				case "$valg" in

					0) 
					;;
					1) read -p "Oppgi nytt fornavn: " ny_fornavn
					;;
					2) read -p "Oppgi nytt etternavn: " ny_etternavn
					;;
					3) read -p "Oppgi ny epost: " ny_epost
					;;
					4) read -p "Oppgi ny gateadr: " ny_gateadr
					;;
					5) read -p "Oppgi nytt postnr: " ny_postnr
					ny_sted=$(mysql -u root -ppetunia -Bse "USE personal;SELECT * FROM postnr WHERE postnr = $ny_postnr")
					cut_sted=$(echo $ny_sted|cut -d" " -f2)
					;;
					7) read -p "Oppgi nytt tlfnr: " ny_tlf
					;;
					8) read -p "Oppgi ny fødselsdato: " ny_f_dato
					;;
					9) read -p "Oppgi ny avdeling: " ny_avd
					;;
					*) echo "Du har ikke tastet et gyldig siffer."
					valg=1
					;;

				esac
			done

			#query='"'
			query+='mysql -u root -p$katt -Bse "USE personal;UPDATE ansatte SET '
			# bygger opp fornavn
			if [ $ny_fornavn != 1048576 ]; then
				query+="fornavn = '"
				query+=$ny_fornavn
				query+="', "
			fi

			# bygger opp etternavn
			if [ $ny_etternavn != 1048576 ]; then
				query+="etternavn = '"
				query+=$ny_etternavn
				query+="', "
			fi

			# bygger opp epost
			if [ "$ny_epost" != 1048576 ]; then
				query+="email = '"
				query+=$ny_epost
				query+="', "
			fi

			# bygger opp gateadr
			if [ "$ny_gateadr" != 1048576 ]; then
				query+="gateadr = '"
				query+=$ny_gateadr
				query+="', "
			fi

			# bygger opp postnr
			if [ $ny_postnr != 1048576 ]; then
				query+="postnr = '"
				query+=$ny_postnr
				query+="', "
			fi

			# bygger opp poststed
			if [ $cut_sted != 1048576 ]; then
				query+="sted = '"
				query+=$cut_sted
				query+="', "
			fi

			# bygger opp tlf
			if [ $ny_tlf != 1048576 ]; then
				query+="telefon = '"
				query+=$ny_tlf
				query+="', "
			fi

			# bygger opp fødselsdato + konvertering
			if [ $ny_f_dato != 1048576 ]; then
				konv_dato=$(mysql -u root -p$katt -Bse "SELECT STR_TO_DATE('$ny_f_dato', '%d-%m-%Y')")
				query+="f_dato = '"
				query+=$konv_dato
				query+="', "
			fi

			# bygger opp avd
			if [ $ny_avd != 1048576 ]; then
				query+="avd = '"
				query+=$ny_avd
				query+="', "
			fi


			query=${query:: -2}

			ansatt_extra=" WHERE ansatt_id = "
			query+=$ansatt_extra
			query+=$ansatt
			query+=';"'

			echo $query
			eval "$query"


			rm edit.tmp
		;;
		4) #slett ansatt
			read -p "Slett ansatt ID: " slett_ansatt

			if [ $slett_id != ]; then
				mysql -u root -p$katt -Bse "USE personal;DELETE FROM ansatte WHERE ansatt_id = $slett_ansatt"
			fi
		;;

		*) echo "Du har ikke tastet et gyldig siffer."
			valg2=1
		;;
		
	esac
done