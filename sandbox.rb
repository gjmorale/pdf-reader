a = true
b = true

puts "#{a} and (not #{b} or #{false})"
puts "#{a} and (#{not b} or #{false})"
puts "#{a} and (#{not b or false})"
puts "#{a and (not b or false)}"