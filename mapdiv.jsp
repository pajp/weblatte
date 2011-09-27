		<script type="text/javascript"
	    		src="http://maps.googleapis.com/maps/api/js?sensor=false">
		</script>
		<script type="text/javascript">
		  function showMap(lat, lng) {
		      var mapdiv = document.getElementById("map_canvas");
		      mapdiv.style.setProperty('height', '30%');
		      mapdiv.style.setProperty('width', '40%');
		      mapdiv.style.setProperty('visibility', 'visible');
		      var latlng = new google.maps.LatLng(lat,lng);
		      var myOptions = {
		            zoom: 8,
			    center: latlng,
			    mapTypeId: google.maps.MapTypeId.ROADMAP
		      };
		      var map = new google.maps.Map(mapdiv, myOptions);
		      var marker = new google.maps.Marker({ position: latlng, map: map, title: "Textens position" });
  		  }

	 	</script>
	    <div id="map_canvas" style="width: 0px; height: 0px; visibility: hidden;"></div>