PQonGmaps
=======

When Groundspeak stopped supporting Google Maps, I hacked this script to parse GPX files
and display then using the Google Maps API.
It started as a personal project, but perhaps someone wants to use (or even contribute) to it...

Installation
------------

`git clone git@github.com:rene-dev/pqongmaps.git`

`rake db:migrate`

Make sure the ruby has permissions to write into `uploads`

`ruby -rubygems app.rb`

upload a gpx file on http://localhost:4567/upload
