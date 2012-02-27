#! /usr/bin/env ruby
# Import gems for Sinatra, XML-parsing and json stuff
require 'rubygems'
require 'bundler'
Bundler.require
require 'json'

class Cache < ActiveRecord::Base
    def self.in_area(lat1,lon1,lat2,lon2)
        where("lat > #{lat2} and lat < #{lat1} and lon > #{lon2} and lon < #{lon1}")
    end
end

class Pqongmaps < Sinatra::Base
  
  # Registering some plugins
  register SinatraMore::RoutingPlugin
  register SinatraMore::MarkupPlugin
  
  # Defining the routes
  map(:home).to("/")
  map(:upload).to("/upload")
  map(:pins).to("/pins.json")
  map(:garmin).to("/garmin")
  
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
  get (:pins) do
    content_type :json
    #ask the database which caches are in the viewport, and return them as json
    Cache.select('name,lat,lon,gc_type').in_area(params['lat1'],params['lon1'],params['lat2'],params['lon2']).to_json
  end

  # Handle GET-request (Show the upload form)
  get (:upload) do
    erb :upload
  end

  # Handle POST-request (Receive and save the uploaded file)
  post (:upload) do
    #save file to uploads folder
    File.open('uploads/' + params['myfile'][:filename], "w") do |f|
      f.write(params['myfile'][:tempfile].read)
    end

    gpx = Nokogiri::XML(File.open('uploads/'+params['myfile'][:filename])) # Open the gpx
    lat = (gpx.css('bounds')[0].values[0].to_f+gpx.css('bounds')[0].values[2].to_f)/2 #parse boundaries of query
    lon = (gpx.css('bounds')[0].values[1].to_f+gpx.css('bounds')[0].values[3].to_f)/2
    old = 0
    new = 0
    #add ALL the caches to the database
    gpx.css('wpt').each do |wpt|
       cache = Cache.find_or_initialize_by_gccode(:name => wpt.css('urlname').inner_text, #add cache to the database
                   :gccode => wpt.css('name').inner_text,
                   :lat  => wpt.values[0],
                   :lon  => wpt.values[1],
                   :gc_type => parse_type(wpt.css('type').inner_text).to_i,
                   :terrain => wpt.css('groundspeak:cache').css('groundspeak:difficulty').inner_text.to_i,
                   :difficulty => wpt.css('groundspeak:cache').css('groundspeak:terrain').inner_text.to_i)
       if cache.persisted? #skip if already in db
        old = old+1
       else
        new = new+1
        cache.save #add new caches to db
       end
    end

    return "Imported #{new} caches, ignored #{old} duplicates"
  end

  get '/' do
    @apikey = '' # Define the GMaps Api key
    erb :index # Call the view
  end

  get (:garmin) do
    erb :garmin # Call the garmin view
  end
end
