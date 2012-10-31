
file_data = {}

curr_line = "didn't work"
lines = []
elevs = []
start_lat = 40
start_lng = -125
step_size = 0.00083333333333333

f = File.open('/Users/jamesharris/Downloads/srtm_12_05/srtm_12_05.asc', 'r')
  6.times do
    puts f.gets
  end

  2605.times do |lat_steps|
    curr_line = f.gets
    if lat_steps >= 2604
      lng_steps = 2982
      10.times do |i|
        lat = start_lat - lat_steps*step_size
        lng = start_lng + (lng_steps + i)*step_size
        elevs = curr_line.split(" ")
        puts "lat steps: " + lat_steps.to_s + " lat: " + lat.to_s + 
            " lng steps: " + lng_steps.to_s + " lng: " + lng.to_s + 
            " elev: " + elevs[lng_steps+i].to_s
      end
    end
  end
f.close

puts "outside loop"


# looking for 37.705 -122.4565 124.8446731567383
# should be ~on line 2761 at col 3052

=begin
  NEXT:
  1. make it work on Heroku
  2. separate maps into a new github project
  2. real url
  2. style it with bootstrap CSS / otherwise make it pretty
  2. avoid loading file when not necessary
  3. display more information - zoom level, max/min elevation shown
  4. mouseover elevation?
  6. redo whole thing in openStreetMap to show elev of blocks/streets
  
  DONE:
  1. relative file path names
  2. clean up the uneccesary stuff / comment
  5. auto-redo heat map upon zoom or view change?
  
  QUESTIONS:
  1. javascript file is huge with huge methods - is there better way to write it?
  2. why doesn't Heroku work?
  3. best way to present this stuff - separate urls? separate GitHub projects? all in one?
  4. better method than heat map?
  5. better to do it in openStreetMap? even for simple grid-based coloring?
  6. how does basic manipulation of OpenStreetMap work?  drawing layers, etc?
=end

