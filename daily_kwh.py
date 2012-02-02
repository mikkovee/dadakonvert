#!/usr/bin/python

import fileinput
import subprocess
import time


p = subprocess.Popen(['lynx', '--dump', 'http://on.tuu.fi/d/tunnit_nyt_teksti.php?id=vs_a4_kwh'], stdout=subprocess.PIPE)

output = p.communicate()[0]

lines = output.splitlines() 
lines.pop(0)
lines.reverse()


firstdate = lines[0].split()[3]
firstkwh =  lines[0].split()[2]

print firstkwh, firstdate

daily = {}

for line in lines:
    #print "line: " + line
    values = line.split()
    #print values
    date = values[3]
    kwh = values[2]
    if date != firstdate:
        #print date
        dailykwh = int(kwh.split(',')[0]) - int(firstkwh.split(',')[0])
        print firstdate, dailykwh
        daily[firstdate] = {"dailykwh":dailykwh} 
        firstdate = date
        firstkwh = kwh
        
    #print type(values)

time.sleep(2)

p2 = subprocess.Popen(['lynx', '--dump', 'http://on.tuu.fi/d/tunnit_nyt_teksti.php?mixa_sisalampotila'], stdout=subprocess.PIPE)
time.sleep(2)
output2 = p2.communicate()[0]
print output2
lines = output2.splitlines() 
lines.pop(0)
lines.reverse()

print lines
firstdate = lines[0].split()[3]
avg_sum = 0
num_temps = 0

for line in lines:
    #print "line: " + line
    values = line.split()
    #print values
    date = values[3]
    avg_sum += values[2]
    num_temps += 1
    if date != firstdate:
        #print date
        
        print firstdate, dailytemp
        daily[firstdate]["temppi"] = avg_sum/num_temps 
        firstdate = date
        firsttemp = temp
        
print daily


