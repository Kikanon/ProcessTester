long() { echo "-h
    show help
-p <path>
    path to file(must specify)
-f <name>
    only find files with name
-l
    list of posel_*.sh
-q
    posel output to /dev/null"
	exit 1; }

noparams() { echo "upravitelj_poslov.sh [-lqh] [-p <path>] [-f <name>]"; exit 1;}

if [ $# -eq 0 ]; then
    noparams
fi

opcijaL=0
noOutput=0

while getopts ":?p:f:lqh" flag
do
	case "${flag}" in
		p) path=${OPTARG};; #obvezno
		f) name=${OPTARG};; #opcija
		l) opcijaL=1;; #druga funkcionalnost
		q) noOutput=1;; #opcija
		h) long;; #druga funkcionalnost
		*) echo "nepricakovana zastavica: ${OPTARG}";;
	esac
done
if [ -z $path ]
then
	noparams
else
	if [[ $opcijaL == 1 ]]
	then
		echo "Imena poslov:"
		find "$path" -type f -name "*.sh" -print0 | while read -r -d $'\0' file
		do
		#echo "Datoteka: $file"
		filename=$(echo  $file | grep -Po "(?<=\/posel_).*(?=.sh)")
		#echo "Grep: $filename"
		if [ ! -z $filename ] #ce ni prazn
		then
			if [ ! -z $name ] #ce je podan parameter -f
			then
				if [[ $filename == *$name* ]]
				then
					echo " $filename"
				fi
			else
				echo " $filename"
			fi
		fi
		done
	else
	good=0 #stevca
	echo "$good" > tempfile.txt
	vsi=0
	echo "$vsi" > tempfile2.txt
	find "$path" -type f -name "*.sh" -print0 | while read -r -d $'\0' file
	do
	filename=$(echo  $file | grep -Po "(?<=\/posel_).*")
	if [ ! -z $filename ] #ce ni prazn
	then
		if [ ! -z $name ] #ce je podan parameter -f
		then
			if [[ $filename == *$name* ]]
			then
				if [[ $noOutput == 1 ]]
				then
					bash $file &>/dev/null
					response=$?
				else
					bash $file
					response=$?
				fi
				vsi=$(cat tempfile2.txt)
				vsi=$((vsi+1))
				echo "$vsi">tempfile2.txt
			fi
		else
			if [[ $noOutput == 1 ]]
			then
				bash $file &>/dev/null
				response=$?
			else
				bash $file
				response=$?
			fi
			vsi=$(cat tempfile2.txt)
			vsi=$((vsi+1))
			echo "$vsi">tempfile2.txt
		fi
		if [[ $response == 0 ]]
		then
			good=$(cat tempfile.txt) #cela zanka je subshell zato moram shranjevat v datoteko
			good=$((good+1))
			echo "$good">tempfile.txt
		fi
	fi
	unset response
	unset filename
	done
		good=$(cat tempfile.txt)
		vsi=$(cat tempfile2.txt)
		echo "$good od $vsi poslov se je izvedlo uspesno."
		rm tempfile.txt
		rm tempfile2.txt
	fi
fi
