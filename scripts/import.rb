#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'colorize'
require 'pp'

def get_geojson(type, uid)
  json = JSON.parse(Net::HTTP.get('frontierspatial.com', '/JanuarySprint/mapper/v1/geometries.php?geojson=true&uid=#{uid}&type=%27#{type}%27'))
  pp json
  json
end
def write_geojson(type, name, uid)
  File.write("./#{type}/#{uid}.geojson", JSON.generate({
    name: name,
    uid: uid,
    geom: get_geojson(type, uid)
  }))
end

puts "Loading FS information..."
geojson_str = Net::HTTP.get('frontierspatial.com', '/JanuarySprint/mapper/v1/geometries.php?geojson=true')
puts "Loaded FS information".green
geojson = JSON.parse(geojson_str)
geojson['features'].each do |feature|
  props = feature['properties']
  case props['type']
  when 'City'
    write_geojson('municipality', "#{props['name']}, #{props['state']}", props['uid'])
  when 'Village'
    write_geojson('municipality', "Villiage of #{props['name']}, #{props['state']}", props['uid'])
  when 'Town'
    write_geojson('municipality', "Town of #{props['name']}, #{props['state']}", props['uid'])
  when 'HUC8 watershed'
    write_geojson('watershed', "#{props['name']} Watershed", props['uid'])
  when 'County'
    write_geojson('county', "#{props['name']} County, #{props['state']}", props['uid'])
  else
    pp props.red
  end
end

#
# ## Import / Update States
# state_geojson_str = Net::HTTP.get('frontierspatial.com','/JanuarySprint/mapper/v1/geometries.php?type=%27State%27&geojson=true')
#
#
# puts "Loading county information..."
# county_geojson_str = Net::HTTP.get('frontierspatial.com','/JanuarySprint/mapper/v1/geometries.php?type=%27County%27&geojson=true')
# puts "Loaded county information".green
# county_geojson = JSON.parse(county_geojson_str)
#
# county_geojson['features'].each do |county_feature|
#   props = county_feature['properties']
#   write_geojson('county', "#{props['name']}, #{props['state']}", props['uid'], county_feature)
# end
#
# puts "Loading town information..."
# town_geojson_str = Net::HTTP.get('frontierspatial.com','/JanuarySprint/mapper/v1/geometries.php?type=%27Town%27&geojson=true')
# puts "Loaded town information".green
# pp town_geojson_str
# town_geojson = JSON.parse(town_geojson_str)
#
# town_geojson['features'].each do |town_feature|
#   props = town_feature['properties']
#   write_geojson('municipality', "Town of #{props['name']}, #{props['state']}", props['uid'], town_feature)
# end
#
# puts "Loading city information..."
# city_geojson_str = Net::HTTP.get('frontierspatial.com','/JanuarySprint/mapper/v1/geometries.php?type=%27City%27&geojson=true')
# pp city_geojson_str
# puts "Loaded city information".green
# city_geojson = JSON.parse(city_geojson_str)
#
# city_geojson['features'].each do |city_feature|
#   props = city_feature['properties']
#   write_geojson('municipality', "#{props['name']}, #{props['state']}", props['uid'], city_feature)
# end
#
# # ## MA Counties
# # dir = "/tmp/ma_counties"
# # file = "#{dir}/download.zip"
# # `rm -rf #{dir}`
# # `mkdir #{dir}`
# # `wget http://wsgw.mass.gov/data/gispub/shape/state/counties.zip -O #{file}`
# # `cd #{dir} && unzip download.zip && ogr2ogr -f "GeoJSON" counties.json COUNTIESSURVEY_POLYM.shp`
# # ma_counties = JSON.parse(File.read("#{dir}/counties.json"))
# # state_geojson['features'].each do |state_feature|
# #
# # end
