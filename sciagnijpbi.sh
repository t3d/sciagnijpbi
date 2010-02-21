#!/bin/bash
#
# based on sciagnijpbi.sh by
# raf_k <at> wp.pl

#spis tresci:
#http://www.pbi.edu.pl/book_reader.php?p=50620&s=1
#spis.php?p=50620&s=1&w=
#konkretne strony
#http://www.pbi.edu.pl/content.php?p=50620&s=2&w=
#tutaj jest ilosc stron
# http://www.pbi.edu.pl/left_1.php?p=50620&s=&w=
#var pages = 846
#publikacje/0000/050/620/0000050620-000003.jpg


TMPDIR=$(mktemp -d)


####Funkcje

getget() {

wget -o $TMPDIR/log.tmp -O"$TMPDIR/$2.html" "$1" &

pid=$!

i=1
 while [ $i -eq 1 ] ; do
   ps -p $pid >/dev/null
   i=$?; 
   sleep 1
 done
}

if [ -z $1 ] ; then
 echo "Nie podales id ksiazki, bez tego nic nie sciagne, wejdz na strone"
 echo "www.pbi.edu.pl otworz interesujaca cie pozycje, szukaj w adresie"
 echo '?p=XXXX np. echo http://www.pbi.edu.pl/content.php?p=50620&s=2&w='
 echo "Spis id jest rowniez w dolaczonym do skryptu katalogu"
 echo "Np. zeby sciagnac obrone Sokratesa nalezy wpisac sh sciagnijpbi.sh 1896"
 exit 1
else
 bookid=$1;
fi

page=1

getget "http://www.pbi.edu.pl/left_1.php?p=$bookid&s=&w=" cover


#echo "Sprawdzam ilo¿¿ stron:"
ii=`cat $TMPDIR/cover.html | grep "var pages"|tr ";" " "| cut -d" " -f4`
#echo "$ii"

dec=`echo "$ii" |wc -L`

#echo "Sprawdzam tytu¿:"
tytul=`cat $TMPDIR/cover.html | grep '<TD class=t11-red><STRONG>'|tr "<>" "||"| cut -d"|" -f5`
tytul=`echo $tytul`
autor=`cat $TMPDIR/cover.html | grep "<TD class=t11-red>"|tail -n1|tr "<>" "||"| cut -d"|" -f3`
autor=`echo $autor`

echo -e "\n[33mZnalazlem ksiazke:[0m"
echo -e " Autor: $autor \n Tytul: $tytul"

sleep 1


echo

page=1

while [ $page -le $ii ] ; do

  source="http://www.pbi.edu.pl/content.php?p=${bookid}&s=${page}&w="

  file=`echo $page|awk {'printf "%0'${dec}'d",$1'}`

  printf "\rSciagam strone $page / $ii "

  getget $source $file 

  page=`expr $page + 1`

done

printf "\n[33mSciaganie zakonczone, lacze pliki.[0m\n"

outputfile="${autor} - ${tytul}.htm"

echo '<html><head><title>Polska Biblioteka Internetowa</title><meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"></title></head><body>' >"${outputfile}"

for i in `ls -1 ${TMPDIR}/[0-9]*.html`; do

#linia=`awk '/class=\"txt\"/ { print $0 }' $i`

awk '/class=\"txt\"/ { print $0 }' $i >>"${outputfile}"

done

rm -fr $TMPDIR

echo '</body></html>' >>"${outputfile}"

printf "\n[33mLaczenie zakonczone\nZapisano plik: [0m"
ls -1 "${outputfile}"

