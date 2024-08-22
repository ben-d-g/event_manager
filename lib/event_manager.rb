require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number_stripped = phone_number.to_s.gsub(/[^0-9]/, '')
  if phone_number_stripped.length == 10
    return phone_number_stripped
  elsif phone_number_stripped.length == 11 and phone_number_stripped[0] == "1"
    return phone_number_stripped.slice(1, 10)
  else
    return "bad number"
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def most_common_hour(date_times)
  hour_frequencies = date_times.reduce({}) do |freq, date_time|
    if freq.keys.include?(date_time.hour)
      freq[date_time.hour] += 1
    else
      freq[date_time.hour] = 1
    end
    freq
  end

  hour_frequencies = hour_frequencies.sort_by{|key, value| value}

  return hour_frequencies[-1][0]
end

def most_common_day(date_times)
  day_frequencies = date_times.reduce({}) do |freq, date_time|
    if freq.keys.include?(date_time.wday)
      freq[date_time.wday] += 1
    else
      freq[date_time.wday] = 1
    end
    freq
  end

  day_frequencies = day_frequencies.sort_by{|key, value| value}

  return case day_frequencies[-1][0]
  when 0
    "Sunday"
  when 1
    "Monday"
  when 2
    "Tuesday"
  when 3
    "Wednesday"
  when 4
    "Thursday"
  when 5
    "Friday"
  when 6
    "Saturday"
  end


  #return day_frequencies[-1][0]
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees_full.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

date_times = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])
  date_times.push(Time.strptime(row[:regdate], "%m/%d/%y %H:%M"))

  #form_letter = erb_template.result(binding)

  #save_thank_you_letter(id,form_letter)
  if date_times.length % 100 == 0
    puts date_times.length
  end
end

puts("Most signups occured at hour #{most_common_hour(date_times)}")
puts("Most signups occured on day #{most_common_day(date_times)}")