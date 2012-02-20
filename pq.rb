#! /usr/bin/env ruby
require 'sinatra'
require 'nokogiri'
require 'json'

def parse_type(type)
    type_no = case type
        when 'Geocache|Unknown Cache' then 8
        when 'Geocache|Traditional Cache' then 2
        when 'Geocache|Multi-cache' then 3
        when 'Geocache|Virtual Cache' then 4
        else 8
    end
    return type_no
end

wpts = Array.new
gpx = Nokogiri::XML(File.open('pq.gpx'))
lat = (gpx.css('bounds')[0].values[0].to_f+gpx.css('bounds')[0].values[2].to_f)/2
lon = (gpx.css('bounds')[0].values[1].to_f+gpx.css('bounds')[0].values[3].to_f)/2

gpx.css('wpt').each do |wpt|
    wpts.push([wpt.css('urlname').inner_text,wpt.values[0],wpt.values[1],parse_type(wpt.css('type').inner_text)])
end

get '/' do
    @apikey = ''
    @lat = lat.to_s
    @lon = lon.to_s
    @pins = wpts.to_json
    erb :index
end
