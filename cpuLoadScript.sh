#!/bin/bash


touch cpuAvglast.txt
cpuLoad=0.0

function snmpData {

 cpuUserT0=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawUser | awk '{print $NF}')
 cpuNiceT0=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawNice | awk '{print $NF}')
 cpuSysT0=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawSystem | awk '{print $NF}')
 cpuIdleT0=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawIdle | awk '{print $NF}')

 cpuAllT0=$(( cpuUserT0 + cpuNiceT0 + cpuSysT0 + cpuIdleT0 ))


  sleep 5s

 cpuUserT1=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawUser | awk '{print $NF}')
 cpuNiceT1=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawNice | awk '{print $NF}')
 cpuSysT1=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawSystem | awk '{print $NF}')
 cpuIdleT1=$(snmpwalk -v 2c -c allInfo 17dcompv008 ssCpuRawIdle | awk '{print $NF}')
 
 cpuAllT1=$(( cpuUserT1 + cpuNiceT1 + cpuSysT1 + cpuIdleT1 ))
         
          
CpuUserAll=$((cpuUserT1-cpuUserT0)) 
CpuAll=$((cpuAllT1-cpuAllT0))

             
cpuLoad=`bc<<<"scale=20 ; 100*$CpuUserAll/$CpuAll"`


    
}   

    
    
    
    
let count=$1/5

for ((i=count; i>0; i--)) #For loop
do
#invoke the function that bring the snmpwalk data
snmpData
echo "$cpuLoad" >> "cpuAvglast.txt"
echo "The CPU user average $cpuLoad ,the loop $i"
done


#This loop well calcualte the Mean (average)=
summation=0.0
count=0
while read line #Read every line and assign to varable $line....    
do
    summation=`bc<<<"scale=20 ; $summation + $line"`
        let count=count+1
done < cpuAvglast.txt

echo "The counter is : $count"
mean=`bc<<<"scale=20;$summation / $count"`
echo "The Average : $mean"



#This loop calcualtes the variance
total=0.0
varP=0.0
while read line #Read every line and assign to varable $line....
do
varP=`bc<<<"scale=20 ; ($line - $mean)^2"`
total=`bc<<<"scale=20 ; ($varP + $total)"`
done < cpuAvglast.txt

let count=count-1

variance=$(bc<<<"scale=20;($total/$count)")
echo "The variance : $variance"

sDev=$(bc<<<"scale=20;sqrt($variance)")
echo "The standard Deviation :$sDev"

#finding the confidence interval
let count=count+1
minVal=`bc<<<"scale=20 ; $mean-(1.96*$sDev)/sqrt($count)"`
maxVal=`bc<<<"scale=20 ; $mean+(1.96*$sDev)/sqrt($count)"`

echo "The confidence interval : [$minVal , $maxVal]"


