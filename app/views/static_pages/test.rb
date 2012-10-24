
file_data = {}

File.open('/Users/jamesharris/rails_projects/sample_app/app/views/static_pages/test.txt', 'r') do |f|
  f.each do |line|
    lat, lng, ele = line.split(" ")
  end
end

puts file_data

=begin
  NEXT:
  1. make it work on Heroku
  2. clean up the uneccesary stuff / comment
  2. separate maps into a new github project
  2. real url
  2. style it with bootstrap CSS
  2. avoid loading file when not necessary
  3. display more information - zoom level, max/min elevation shown
  4. mouseover elevation?
  5. auto-redo heat map upon zoom or view change?
  6. redo whole thing in openStreetMap to show elev of blocks/streets
  
  DONE:
  1. relative file path names
=end

