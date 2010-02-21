#!/bin/bash
# Sciagnijpbi  v 0.5 beta
# Public domain, czyli mo¿esz robiæ z nim co chcesz, a ja za nic nie odpowiadam :)
# Skrypt powinien sciagnac ksiazki z www.pbi.edu.pl
# Dokladniejsza instrukcja i katalog w dolaczonych plikach
# raf_k(tu ma³pa)wp(tu kropka)pl
#
#spis tresci:
#http://www.pbi.edu.pl/book_reader.php?p=50620&s=1
#spis.php?p=50620&s=1&w=
#konkretne strony
#http://www.pbi.edu.pl/content.php?p=50620&s=2&w=
#tutaj jest ilosc stron
# http://www.pbi.edu.pl/left_1.php?p=50620&s=&w=
#var pages = 846
#publikacje/0000/050/620/0000050620-000003.jpg


#katalog na sci¹gniete ksiazki
booksdir=ksiazki

#Pliki tymczasowe  uwaga, skasuje tam wszystkie pliki zaczynaj¹ce siê od cyfry a konczace .html
dir=tmp

mkdir $dir > /dev/null 2>&1 
mkdir $booksdir > /dev/null 2>&1 

rm ${dir}/[0-9]*.html > /dev/null 2>&1 

 if [ -z $1 ] ; then 
 echo "Nie podales id ksiazki, bez tego nic nie sciagne, wejdz na strone"
 echo "www.pbi.edu.pl otworz interesujaca cie pozycje, szukaj w adresie"
 echo '?p=XXXX np. echo http://www.pbi.edu.pl/content.php?p=50620&s=2&w='
 echo "Spis id jest rowniez w dolaczonym do skryptu katalogu"
 echo "Np. zeby sciagnac obrone sokratesa nalezy wpisac sh sciagnijpbi.sh 1896"
 exit 1
 #bookid=50620
 else 
  
  bookid=$1;
#  bookid=50620  #dante boska
  fi


####Funkcje

function getget {
#	return


wget -o $dir/log.tmp -O"$dir/$2.html" "$1" &

pid=$!
#printf "\n\n\n###\n\n $pid\n\n#####\n\n"

i=1
 while [ $i -eq 1 ] ; do
   ps -p $pid >/dev/null
   i=$?; 
  # printf "." ; 
   sleep 1
 done

}

####################################

# PROGRAM

####################################


page=1

getget "http://www.pbi.edu.pl/left_1.php?p=$bookid&s=&w=" cover


#echo "Sprawdzam ilo¿¿ stron:"
ii=`cat $dir/cover.html | grep "var pages"|tr ";" " "| cut -d" " -f4`
#echo "$ii"

dec=`echo "$ii" |wc -L`



#cat $dir/cover.html | grep '<TD class=t11-red><STRONG>'|tr "<>" "||"| cut -d"|" -f5

#echo "Sprawdzam tytu¿:"
tytul=`cat $dir/cover.html | grep '<TD class=t11-red><STRONG>'|tr "<>" "||"| cut -d"|" -f5`
tytul=`echo $tytul`
autor=`cat $dir/cover.html | grep "<TD class=t11-red>"|tail -n1|tr "<>" "||"| cut -d"|" -f3`
autor=`echo $autor`


printf "\n"
echo "[33mZnalazlem ksiazke:[0m"
echo " Autor: $autor"
echo " Tytul: $tytul"

 sleep 1


#mkdir -p "$autor"

#dir="$autor/"
echo

page=1

while [ $page -le $ii ] ; do

  source="http://www.pbi.edu.pl/content.php?p=${bookid}&s=${page}&w="

  file=`echo $page|awk {'printf "%0'${dec}'d",$1'}`

  printf "\rSciagam strone $page / $ii "

  getget $source $file 

  page=`expr $page + 1`

done

printf "\n[33mSciaganie zakonczone, lacze pliki:[0m\n"

outputfile="$booksdir/${autor} - ${tytul}.htm"

echo '<html><head><title>Polska Biblioteka Internetowa</title><meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"></title></head><body>' >"${outputfile}"

for i in `ls -1 ${dir}/[0-9]*.html`; do

#linia=`awk '/class=\"txt\"/ { print $0 }' $i`

awk '/class=\"txt\"/ { print $0 }' $i >>"${outputfile}"

done


echo '</body></html>' >>"${outputfile}"

printf "\n[33mLaczenie zakonczone\nZapisano plik: [0m"
ls -1 "${outputfile}"

