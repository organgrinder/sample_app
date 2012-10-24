
file_data = {}

File.open('/Users/jamesharris/rails_projects/sample_app/app/views/static_pages/test.txt', 'r') do |f|
  f.each do |line|
    lat, lng, ele = line.split(" ")
  end
end

puts file_data

=begin
  NEXT:
  2. avoid loading file when not necessary
  3. display more information - zoom level, max/min elevation shown
  4. mouseover elevation?
  5. auto-redo heat map upon zoom or view change?
  
  DONE:
  1. relative file path names
=end

