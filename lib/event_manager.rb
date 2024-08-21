require("csv")
puts('Event Manager Initialized!')

def clean_zipcode(zipcode)
  return zipcode.to_s.rjust(5, "0").slice(0,5)
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name, zipcode = row[:first_name], row[:zipcode]

  zipcode = clean_zipcode(zipcode)

  puts("#{name}, #{zipcode}")
end