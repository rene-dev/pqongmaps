function initialize() {
    var myOptions = {
		center: new google.maps.LatLng(51.48895, 7.424133),
        zoom: 5,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    google.maps.event.addListener(map, 'idle', showMarkers);
    var infowindow = new google.maps.InfoWindow();

    function showMarkers() {
        var bounds = map.getBounds();
        var southWest = bounds.getSouthWest();
        var northEast = bounds.getNorthEast();
        var lat1 = northEast.lat();
        var lon1 = northEast.lng();
        var lat2 = southWest.lat();
        var lon2 = southWest.lng();
        // Call you server with ajax passing it the bounds
        console.log("reloading markers");
        $.getJSON("/pins.json?", {
            lat1: lat1,
            lon1: lon1,
            lat2: lat2,
            lon2: lon2
        }, function (data) {
            $.each(data, function (i, item) {
                cache = item['cache'];
                var myLatLng = new google.maps.LatLng(cache['lat'], cache['lon']);
                var image = 'img/' + cache['gc_type'] + '.gif';
                marker = new google.maps.Marker({
                    position: myLatLng,
                    map: map,
                    icon: image,
                    title: cache['name'],
                    html: 'name: ' + cache['name']
                });

                google.maps.event.addListener(marker, 'click', function (marker, i) {
                    infowindow.setContent(this.html);
                    infowindow.open(map, this);
                });
                //console.log(item[0]);
            });
        });
        // In the ajax callback delete the current markers and add new markers
    }

    if (navigator.geolocation) { // If the browser can geolocate the user...
        navigator.geolocation.getCurrentPosition(

        function (position) { // ...and the user allows it...
            var posLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            var image = 'img/blue_circle.gif';
            marker = new google.maps.Marker({
                position: posLatLng,
                map: map,
                icon: image,
                title: 'Geolocation',
                html: 'name: Geolocation'
            });
            google.maps.event.addListener(marker, 'click', function (marker, i) { // ...set a marker to user's position.
                infowindow.setContent(this.html);
                infowindow.open(map, this);
            });
			google.maps.setCenter(posLatLng);
			google.maps.setZoom(13);
        }, function () {});
    } 
}
