#! /usr/bin/env ruby
# Import gems for Sinatra, XML-parsing and json stuff
require 'sinatra'
require 'sinatra/activerecord'
require 'nokogiri'
require 'json'
require 'haml'

class Cache < ActiveRecord::Base
end

def parse_type(type) # Parse the type of the cache for proper image displaying
    type_no = case type
        when 'Geocache|Unknown Cache' then 8
        when 'Geocache|Traditional Cache' then 2
        when 'Geocache|Multi-cache' then 3
        when 'Geocache|Virtual Cache' then 4
        else 8
    end
    return type_no
end

#every time the viewport of the map changes, a callback gets the pins
#for the new viewport from this json file.
get '/pins.json' do
    content_type :json
    #ask the database which caches are in the viewport, and return them as json
    Cache.select('name,lat,lon,gc_type').where("lat > #{params['lat2']} and lat < #{params['lat1']} and lon > #{params['lon2']} and lon < #{params['lon1']}").to_json
end

# Handle GET-request (Show the upload form)
get '/upload' do
    haml :upload
end

# Handle POST-request (Receive and save the uploaded file)
post "/upload" do
    #save file to uploads folder
    File.open('uploads/' + params['myfile'][:filename], "w") do |f|
        f.write(params['myfile'][:tempfile].read)
    end

    gpx = Nokogiri::XML(File.open('uploads/'+params['myfile'][:filename])) # Open the gpx
    lat = (gpx.css('bounds')[0].values[0].to_f+gpx.css('bounds')[0].values[2].to_f)/2 #parse boundaries of query
    lon = (gpx.css('bounds')[0].values[1].to_f+gpx.css('bounds')[0].values[3].to_f)/2

    #add ALL the caches to the database
    gpx.css('wpt').each do |wpt|
      Cache.create(:name => wpt.css('urlname').inner_text, #add cache to the database
                   :lat  => wpt.values[0],
                   :lon  => wpt.values[1],
                   :gc_type => parse_type(wpt.css('type').inner_text).to_i)
    end
   
    return "The file was added to the database."
end

get '/' do
    @apikey = '' # Define the GMaps Api key
    haml :index # Call the view
end

get '/garmin' do
    erb :garmin # Call the garmin view
end
