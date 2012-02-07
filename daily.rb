#!/usr/bin/ruby1.9.1
# -*- coding: iso-8859-1 -*-

#PRAGMA foreign_keys=OFF;
#BEGIN TRANSACTION;
#CREATE TABLE dada( date TEXT PRIMARY KEY, temp_in REAL, temp_out REAL, kwh INTEGER);
#INSERT INTO "dada" VALUES('2010-10-03',2.0,3.0,4);
#INSERT INTO "dada" VALUES('2010-10-04',2.0,3.0,4);
#COMMIT;

require 'nokogiri'
require 'sqlite3'
require 'open-uri'
require 'logger'

$log = Logger.new('log.txt')
$log.level = Logger::DEBUG

kwh = Nokogiri::HTML(open('http://on.tuu.fi/d/tunnit_nyt_teksti.php?id=vs_a4_kwh&aika=24'))
ulko = Nokogiri::HTML(open('http://on.tuu.fi/d/tunnit_nyt_teksti.php?id=32_ulkolampotila&aika=24'))
sisa = Nokogiri::HTML(open('http://on.tuu.fi/d/tunnit_nyt_teksti.php?id=mixa_sisalampotila&aika=24'))


$db = SQLite3::Database.open( "test.db" )



#
def update_db(date, col, value)
  res = $db.execute("select * from dada where date='" + date + "'")
  #$log.debug res
  if res != []
    query = "update dada set " + col + "='" + value.to_s + "' where date='"+ date + "'"
    $log.debug query
    $db.execute(query)
  else
    query = "insert into dada (temp_out, date) values (" + value.to_s + ",'" + date +"')"
    $log.debug query
    $db.execute(query)
  end
end


# parsi on tuu fi weppisivun arvoista päiväkeskiaorvot
# suoltaa kantaan sarakkeeseen col
def daily_avg(doc, col, since=" ")
  doc.css("tr").first.remove

  first = doc.css("tr").first.css("td").first.content
  sum = 0
  num = 0
  $log.debug "first from web "+ first+ "\n"

  #laske keskiarvo, lisää/päivitä tietokantaan täh
  doc.css("tr").each { |row| 
    current = row.css("td").first.content
    $log.debug "first "+ first+" current "+current+" last "+ since+"\n"
    if first == current
      sum += row.css("td")[2].content.to_i
      num += 1
    else
      if num == 0
        avg = -42
      else
        avg = sum / num
      end

      update_db(first, col, avg)
      sum = 0
      num = 0
      sum =  row.css("td")[2].content.to_i
      first = row.css("td").first.content
      #$log.debug "avg: "+avg+" "+ current+ "\n"
    

    end
    $log.debug "current "+ current+ " last "+ since+ "\n"
    break row if since == current
  }
end


# parsi on tuu fi weppisivun arvoista päiväsummat kilowateille
# suoltaa kantaan sarakkeeseen col
def daily_sum(doc, col, since=" ")
  doc.css("tr").first.remove

  first_date = doc.css("tr").first.css("td").first.content
  sum = 0
  $log.debug "first from web "+ first_date + "\n"
  first_data = doc.css("tr").first.css("td")[2].content.to_i

  #laske summa, lisää/päivitä tietokantaan täh
  doc.css("tr").each { |row| 
    #print row.to_s + "\n"
    current_date = row.css("td").first.content
    #$log.debug "first "+ first_data+" current "+current_data+" last "+ since+"\n"
    if first_date != current_date
      current_data =  row.css("td")[2].content.to_i
      total = first_data - current_data
      print "total = " + total.to_s + " first " + first_data.to_s + " current " + current_data.to_s +  "\n"
      first_data = current_data
      #$log.debug "daily for "+ current+ " "+ total+ "\n"
      update_db(first_date, col, total)
  
      first_date = row.css("td").first.content
      #$log.debug "avg: "+avg+" "+ current+ "\n"
    

    end
    #$log.debug "current "+ current+ " last "+ since+ "\n"
    break row if since == current_date
  }
end

#this is the main 

last = " "
if ARGV[0] == "all"
  last = " "
  $log.debug("update all")
else
  last = $db.execute( "select max(date) from dada" )[0][0]
  $log.debug "Update data since " + last 
end

daily_avg(ulko, "temp_out", last)
daily_avg(sisa, "temp_in", last)
daily_sum(kwh, "kwh", last)

$db.close()
