require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip, levels: 'country', roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_homephone(homephone)
  homephone.gsub!(/[^\w]/, '').to_s

  if homephone.length == 11 && homephone.start_with?('1')
    homephone[1..10]
  elsif homephone.length != 10
    'Please provide a valid phone number to receive mobile alerts.'
  else
    homephone
  end
end

def registration_count(array)
  array.max_by { |a| array.count(a) }
end

puts "\nEvent Manager Initialized!"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
hour = []
day = []
count = 0

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = clean_homephone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  reg_date = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')
  hour[count] = reg_date.hour
  day[count] = reg_date.strftime('%A')
  count += 1

  # puts "Day = #{reg_date_to_print.strftime('%A')}"
  # puts "Time = #{reg_date.strftime('%H:%M')}"

  puts "#{name} #{phone}"

  save_thank_you_letter(id, form_letter)
end

puts "\nThe most common registration day is #{registration_count(day)}"
puts "The most common registration hour is #{registration_count(hour)}:00\n\n"
