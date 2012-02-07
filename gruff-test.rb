#!/usr/bin/ruby1.9.1


require 'rubygems'
require 'gruff'
require 'sqlite3'

def unnil(value)
  if value == nil 
    value = 0
  end
  return value.to_i
end

days = 7

$db = SQLite3::Database.open( "test.db" )

res = $db.execute("select * from dada where temp_in is not null and date > date('now','-" + days.to_s + " days') order by date")

labels = []
sisa = []
ulko = []
watit = []

res.each { |row| 
labels.push(row[0]) 
sisa.push(unnil(row[1]))
ulko.push(unnil(row[2]))
watit.push(unnil(row[3]))
}

g = Gruff::Line.new


g.title = labels[0].to_s + " - " + labels[days.to_i - 1].to_s 

g.data("Sisa", sisa)
g.data("Ulko", ulko)
g.data("Watit", watit)

g.y_axis_increment = 10
g.minimum_value = -20
g.maximum_value = 60

g.hide_values = false

key = 0
labels.each{ |label|
  if key.modulo(2) == 0
    g.labels[key] = label
  end 
  key += 1
} 



g.write('my_fruity_graph.png')
