require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
  case phone.to_s.length
  when 10 then phone.to_s
  when 11 then phone.to_s[1..10]
  end
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hourtime = Hash.new(0)
daytime = Hash.new(0)
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = row[:homephone].gsub(/[^\d]/, '')
  date = DateTime.strptime(row[:regdate], '%m/%d/%Y  %H:%M')
  ora = date.hour
  giorno = date.strftime("%A")
  hourtime[ora] += 1
  daytime[giorno] += 1
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(phone)
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end

print Hash[hourtime.sort_by{|k, v| v}.reverse]
puts 
print Hash[daytime.sort_by{|k, v| v}.reverse]
puts