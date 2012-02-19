require 'sinatra'
require 'nokogiri'
require 'json'

wpts = Array.new
gpx = Nokogiri::XML(File.open('pq.gpx'))
gpx.css('wpt').each do |wpt|
    wpts.push([wpt.css('urlname').inner_text,wpt.values[0],wpt.values[1]])
end

get '/' do
    @apikey = ''
    @pins = wpts.to_json
    erb :index
end
