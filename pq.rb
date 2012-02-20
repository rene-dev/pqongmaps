#! /usr/bin/env ruby
# Import gems for Sinatra, XML-parsing and json stuff
require 'sinatra'
require 'nokogiri'
require 'json'

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

get '/pins.json' do
    content_type :json
    logger.info params['lat1']
    logger.info params['lon1']
    #dont care, just return ALL the markers
    wpts.to_json
end

get '/' do
  if File.exists?('pq.gpx') # If the gpx is available
    wpts = Array.new
    gpx = Nokogiri::XML(File.open('pq.gpx')) # Open the gpx
    lat = (gpx.css('bounds')[0].values[0].to_f+gpx.css('bounds')[0].values[2].to_f)/2 # And parse it into the coordinates...
    lon = (gpx.css('bounds')[0].values[1].to_f+gpx.css('bounds')[0].values[3].to_f)/2

    gpx.css('wpt').each do |wpt|
      wpts.push([wpt.css('urlname').inner_text,wpt.values[0],wpt.values[1],parse_type(wpt.css('type').inner_text)]) # ...and the waypoint array
    end
    @apikey = '' # Define the GMaps Api key
    @lat = lat.to_s # Export the coordinates
    @lon = lon.to_s
    erb :index # Call the view
  else
    "Pocket Query existiert nicht, oder ist nicht lesbar." # Else fail
  end
end

get '/garmin' do
    erb :garmin # Call the garmin view
end
