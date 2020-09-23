#!/bin/bash
source $HOME/.bash_profile
cd /tmp
log=mc${$}.txt
rootNum=`id |awk '{print $1}'|grep -w "root"|uniq|wc -l`
if [ $rootNum -eq 1 ];then
cat /etc/passwd | cut -f 1 -d : |egrep "root|mysql"|xargs -I {} crontab -l -u {} 2>/dev/null|sed '/^#.*\|^$/d' > $log
else
crontab -l 2>/dev/null|sed '/^#.*\|^$/d' > $log
fi
shopt -s expand_aliases
#shopt expand_aliases
alias keywordLmatchCMD=$(echo 'echo "$line"|awk -v RS="@#$j" '"'"'{print gsub(/'"'"'"$KEYWORD"'"'"'/,"&")}'"'")
alias keywordTmatchCMD=$(echo 'awk -v RS="@#$j" '"'"'{print gsub(/'"'"'"$KEYWORD"'"'"'/,"&")}'"'"' "$script"')
if [ ! -s $log ];then
stdopt="unmatched"
else
#echo "...START1..."
arrkeyword[0]="xtrabackup"
arrkeyword[1]="innobackupex"
arrkeyword[2]="mysqlbackup"
arrkeyword[3]="mariabackup"
#for keyword in ${arrkeyword[@]}
#do
#   echo $keyword
#done
Nlines=`cat $log|wc -l`
i=0
while read line
do
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "xtrabackup" ];then
KEYWORD="xtrabackup"
PXBmatchNum=`keywordLmatchCMD`
elif [ "$keyword" == "innobackupex" ];then
KEYWORD="innobackupex"
IBmatchNum=`keywordLmatchCMD`
elif [ "$keyword" == "mysqlbackup" ];then
KEYWORD="mysqlbackup"
MEBmatchNum=`keywordLmatchCMD`
elif [ "$keyword" == "mariabackup" ];then
KEYWORD="mariabackup"
MBmatchNum=`keywordLmatchCMD`
fi
done
#echo $PXBmatchNum
#echo $IBmatchNum
#echo $MEBmatchNum
#echo $MBmatchNum
if [ $PXBmatchNum -ne 0 ] || [ $IBmatchNum -ne 0 ] || [ $MEBmatchNum -ne 0 ] || [ $MBmatchNum -ne 0 ];then
stdopt="matched"
break
else
let i++
#echo $i
if [[ $Nlines -eq $i ]];then
stdopt="unmatched"
break
fi
fi
done < $log
#echo $stdopt
if [ "$stdopt" == "unmatched" ];then
#echo "...START2..."
arrshell[0]="sh"
arrshell[1]="bash"
arrshell[2]="/bin/sh"
arrshell[3]="/bin/bash"
arrshell[4]="/usr/bin/sh"
arrshell[5]="/usr/bin/bash"
while read line
do
shell=`echo "$line"|awk '{print $6}'`
j=0
for arr in ${arrshell[@]}
do
if [ "$arr" == "$shell" ];then
let j++
fi
done
if [ $j -eq 1 ];then
#echo "withshell"
script=`echo "$line"|awk '{print $7}'`
test -e "$script"
if [ $? -eq 0 ];then
#Stricter matching patterns are recommended
scriptNum=$(file "$script"|egrep -w "text executable|text"|wc -l)
if [ $scriptNum -eq 1 ];then
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "xtrabackup" ];then
KEYWORD="xtrabackup"
PXBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "innobackupex" ];then
KEYWORD="innobackupex"
IBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mysqlbackup" ];then
KEYWORD="mysqlbackup"
MEBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mariabackup" ];then
KEYWORD="mariabackup"
MBmatchNum=`keywordTmatchCMD`
fi
done
#echo $PXBmatchNum
#echo $IBmatchNum
#echo $MEBmatchNum
#echo $MBmatchNum
if [ $PXBmatchNum -ne 0 ] || [ $IBmatchNum -ne 0 ] || [ $MEBmatchNum -ne 0 ] || [ $MBmatchNum -ne 0 ];then
stdopt="matched"
break
fi
fi
fi
else
#echo "withNoshell"
script=`echo "$line"|awk '{print $6}'`
test -e "$script"
if [ $? -eq 0 ];then
#Stricter matching patterns are recommended
scriptNum=$(file "$script"|egrep -w "text executable|text"|wc -l)
if [ $scriptNum -eq 1 ];then
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "xtrabackup" ];then
KEYWORD="xtrabackup"
PXBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "innobackupex" ];then
KEYWORD="innobackupex"
IBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mysqlbackup" ];then
KEYWORD="mysqlbackup"
MEBmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mariabackup" ];then
KEYWORD="mariabackup"
MBmatchNum=`keywordTmatchCMD`
fi
done
#echo $PXBmatchNum
#echo $IBmatchNum
#echo $MEBmatchNum
#echo $MBmatchNum
if [ $PXBmatchNum -ne 0 ] || [ $IBmatchNum -ne 0 ] || [ $MEBmatchNum -ne 0 ] || [ $MBmatchNum -ne 0 ];then
stdopt="matched"
break
fi
fi
fi
fi
done < $log
fi
fi
echo $stdopt
test -e $log && rm -f $log
#./debug.sh