require 'csv'
puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv', 
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]

# if the zipcode is 5 digits its ok
# if the zipcode has more than 5 digits, reduce it to the first 5 digits
# if the zipcode is less than 5 digits add 00s to the start until it is 5 digits

  puts "#{name} #{zipcode}"
end




