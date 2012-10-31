var map, elevHeatmap, cubes;

var gradient = [
   'rgba(0, 255, 255, 0)',
	'rgba(0, 255, 255, 1)',
	'rgba(0, 191, 255, 1)',
	'rgba(0, 127, 255, 1)',
	'rgba(0, 63, 255, 1)',
	'rgba(0, 0, 255, 1)',
	'rgba(0, 0, 223, 1)',
	'rgba(0, 0, 191, 1)',
	'rgba(0, 0, 159, 1)',
	'rgba(0, 0, 127, 1)',
	'rgba(63, 0, 91, 1)',
	'rgba(127, 0, 63, 1)',
	'rgba(191, 0, 31, 1)',
	'rgba(255, 0, 0, 1)'];

google.maps.event.addDomListener(window, 'load', initialize)

function initialize() {
	
	var SanFran = new google.maps.LatLng(37.755, -122.436);
	var myLatLong = SanFran;
	
	// initialize map
	var mapOptions = {
		center: myLatLong,
		zoom: 13,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		disableDefaultUI: false,
		scaleControl: true,
		zoomControl: false,
		panControl: false,
		streetViewControl: false,
		zoomControlOptions: {
			style: google.maps.ZoomControlStyle.SMALL,
		}
	};

    map = new google.maps.Map(document.getElementById("map_canvas"),
           mapOptions);

	// elevator used in pulling elevation data from Google API
	elevator = new google.maps.ElevationService();
	
	//additional vars for gathering elevations
	cubes = [];	
	density = 6;
	
	for (var i=0; i<density*density; i++) {
		cubes[i] = new google.maps.Polygon({ });
		cubes[i].setMap(map);
	}
	
	google.maps.event.addListener(map, 'idle', showElevations);
	
} // end initialize

const LAT_INCREMENT = .0008333333333333;
const LNG_INCREMENT = .0008333333333333;

// gatherGridElevations used only to pull data which is stored in file on server
// does not have ongoing purpose
// could be redone to allow user to pull data for his location

function gatherGridElevations(event) {
	var top = 37.830
	var left = -122.515; // left side of square
	var squareSide = 125;
	var bottom = top - squareSide * LAT_INCREMENT;
	var right = left + squareSide * LNG_INCREMENT;
	
	var numRequests = 10;
	
	var currentFile;
	
	var recordPuller = new XMLHttpRequest();
	
	recordPuller.onreadystatechange = function() {
		if(recordPuller.readyState == 4) {
			currentFile = recordPuller.responseText;
		} else {
			return;
		}
	}
	
	// pulls the entire elevations file just to look at the last line
	// more efficient would be for 'sender' action to just return the last line
	
	// recordPuller.open("GET", "sender?file=elevations_new_grid.txt", false);
	// recordPuller.send()
	// 
	// var lines = currentFile.split("\n");
	// var lastLine = lines[lines.length-2]
	// var lastLineItems = lastLine.split(" ");

	// pull starting point from file
	// var currLat = parseFloat(lastLineItems[0]);
	// var currLng = parseFloat(lastLineItems[1]);
	
	// on first time running, hard-code starting point
	var currLat = top;
	var currLng = left - LNG_INCREMENT;
	
	var locations = [];
	
	for (var i = 0; i < numRequests; i++) {
		// failed attempt to fix trailing string of 9's or 0...01
		// currLng = Math.round((currLng + LNG_INCREMENT) * 10000) / 10000;
		currLng += LNG_INCREMENT;
		if (currLng > right) {
			currLng = left + LNG_INCREMENT;
			currLat -= LAT_INCREMENT;
			if (currLat < bottom) {
				break;
			}
		}
		// don't understand why I can't say 'locations += new google.maps... '
		locations[i] = new google.maps.LatLng(currLat, currLng);
	}
	
	var positionalRequest = { 'locations': locations }
	
	elevator.getElevationForLocations(positionalRequest, function(results, status) {
		if (status == google.maps.ElevationStatus.OK) {
			// appears to be good elevation request
		} else {
			if (status == google.maps.ElevationStatus.OVER_QUERY_LIMIT) {
				document.getElementById("test_output").innerHTML += 'Query Limit Reached';
			} else {
				document.getElementById("test_output").innerHTML += 'Something unknown wrong';
			}
		}	
		var postString = "length=" + results.length + "&file=elevations_new_grid.txt";

		for (var i=0; i<results.length; i++) {
			postString += 	"&ele" + i + "=" + results[i].elevation + 
							"&res" + i + "=" + results[i].resolution + 
							"&lat" + i + "=" + locations[i].lat() +
							"&lng" + i + "=" + locations[i].lng()
		}

		var xhr = new XMLHttpRequest();
		
		xhr.onreadystatechange = function() {
			if(xhr.readyState == 4) {
				// some kind of success message
			}
		}

		xhr.open("POST", 'record', true);
		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xhr.send(postString);
		
	});

} // end gatherGridElevations

function showElevations(event) {
	var dataString = 	"37.780 -122.430 32.49013519287109 \
						37.780 -122.432 29.66671943664551 \
						37.780 -122.434 22.37393188476562 \
						37.780 -122.436 80.25514221191406 \
						37.780 -122.438 96.3092041015625 \
						37.781 -122.430 69.87810516357422 \
						37.781 -122.432 45.20539093017578 \
						37.781 -122.434 45.39119338989258 \
						37.781 -122.436 61.73223876953125 \
						37.781 -122.438 35.80148315429688 \
						37.782 -122.430 21.24711990356445 \
						37.782 -122.432 94.37227630615234 \
						37.782 -122.434 48.39481353759766 \
						37.782 -122.436 34.74443054199219 \
						37.782 -122.438 31.88492393493652 \
						37.783 -122.430 21.54588508605957 \
						37.783 -122.432 12.73579597473145 \
						37.783 -122.434 73.46012878417969 \
						37.783 -122.436 63.4591178894043 \
						37.783 -122.438 45.91290283203125 \
						37.784 -122.430 20.77692985534668 \
						37.784 -122.432 16.33996200561523 \
						37.784 -122.434 7.308896541595459 \
						37.784 -122.436 72.64293670654297 \
						37.784 -122.438 68.78495025634766 \
						37.785 -122.430 47.55492401123047 \
						37.785 -122.432 24.4963264465332 \
						37.785 -122.434 8.531320571899414 \
						37.785 -122.436 6.679337501525879 \
						37.785 -122.438 113.2409133911133 \
						37.786 -122.430 3.934934377670288 \
						37.786 -122.432 63.0922966003418 \
						37.786 -122.434 78.76312255859375 \
						37.786 -122.436 43.56306457519531 \
						37.786 -122.438 90.13072204589844";

	var elevations = [];
	var heatmapElevData = [];

	// using data from above
/*
	var dataArray = dataString.split(" ");
	
	for (var i=0;i<dataArray.length/3;i++) {
		elevations[i] = dataArray[i*3+2];
	}

	var maxElevation = Math.max.apply(Math, elevations);
	
	for (var i=0;i<dataArray.length;i+=3) {
		heatmapElevData.push({ 
			location: new google.maps.LatLng(
				dataArray[i], 
				dataArray[i+1]), 
				weight: (dataArray[i+2] / maxElevation
			) 
		});
	}
*/
	
	// using data from file on server

	var currentFile;
	var recordPuller = new XMLHttpRequest();
	
	recordPuller.onreadystatechange = function() {
		if(recordPuller.readyState == 4) {
			currentFile = recordPuller.responseText;
		} else {
			return;
		}
	}
		
	recordPuller.open("GET", "sender?file=elevations.txt", false);
	recordPuller.send()
	
	var lines = currentFile.split("\n");

	// get bounds of current view to test what points are in the view
	var currBounds = map.getBounds();
	var top = currBounds.getNorthEast().lat();
	var bottom = currBounds.getSouthWest().lat();
	var left = currBounds.getSouthWest().lng();
	var right = currBounds.getNorthEast().lng();

	// there's prob a more elegant way to do this
	var maxElevation = -Infinity;
	var minElevation = 30000; 
	
	var linesToInclude = [];
	
	// test if each point is in view and not water
	// and update max- and minElevation if necessary
	for (var i = 0; i < lines.length-1; i++) {
		var lineItems = lines[i].split(" ");
		
		if (lineItems[0] > bottom && lineItems[0] < top && 
			lineItems[1] > left && lineItems[1] < right &&
			lineItems[2] > 0) { 
				linesToInclude.push(lines[i]);
				maxElevation = Math.max(maxElevation, lineItems[2]);
				minElevation = Math.min(minElevation, lineItems[2]);
		}
	}

	// create data array using points in view and appropriate weights
	for (var i = 0; i < linesToInclude.length; i++) {
		var lineItems = linesToInclude[i].split(" ");
		heatmapElevData.push({ 
			location: new google.maps.LatLng(lineItems[0], lineItems[1]), 
			weight: ((lineItems[2] - minElevation) / (maxElevation - minElevation)) 
		});
	}
	
	// load additional data at zoom 15 and above
	if (map.getZoom() >= 15) { 
		var recordPuller3 = new XMLHttpRequest();

		recordPuller3.onreadystatechange = function() {
			if(recordPuller3.readyState == 4) {
				currentFile = recordPuller3.responseText;
			} else {
				return;
			}
		}

		recordPuller3.open("GET", "sender?file=elevations3.txt", false);
		recordPuller3.send()

		var lines = currentFile.split("\n");

		// same tests for whether point is in view and not water
		for (var i = 0; i < lines.length-1; i++) {
			var lineItems = lines[i].split(" ");

			if (lineItems[0] > bottom && lineItems[0] < top && 
				lineItems[1] > left && lineItems[1] < right &&
				lineItems[2] > 0) { 
					heatmapElevData.push({ 
						location: new google.maps.LatLng(lineItems[0], lineItems[1]), 
						weight: (lineItems[2] / maxElevation) 
					});
			}
		}
	}
	
	// repeat more points at higher zoom levels
/*
	if (map.getZoom() > 15) { 
		var stop = heatmapElevData.length; // to avoid infinite loop
		for (var i = 0; i < stop; i++) {
			heatmapElevData.push({ 
				location: new google.maps.LatLng(
					heatmapElevData[i].location.lat(), 
					parseFloat(heatmapElevData[i].location.lng()) - LNG_INCREMENT / 2), 
				weight: heatmapElevData[i].weight
			});
		}
	}
*/

	// increase influence radius at higher zooms
	var influence = 10;
	if (map.getZoom() >= 13) { influence = 15; }
	if (map.getZoom() >= 14) { influence = 30; }
	if (map.getZoom() >= 15) { influence = 45; } // additional data loaded at zoom 15 as well
	if (map.getZoom() >= 16) { influence = 80; } 
	if (map.getZoom() >= 17) { influence = 110; } 
	
		
	// add all points regardless of zoom level
/*
	for (var i = 0; i < lines.length-1; i++) {
		var lineItems = lines[i].split(" ");
		if (lineItems[2] > 0) { // exclude water
			heatmapElevData.push({ 
				location: new google.maps.LatLng(
					lineItems[0], 
					lineItems[1]), 
					weight: (lineItems[2] / 200
				) 
			});
		}
		// repeat each point half-step up and half-step over for density purposes
		// increasing influence works just as well, and is easier
		
		// heatmapElevData.push({ 
		// 	location: new google.maps.LatLng(
		// 		parseFloat(lineItems[0]) + LAT_INCREMENT / 2, 
		// 		parseFloat(lineItems[1]) + LNG_INCREMENT / 2), 
		// 		weight: (lineItems[2] / 200
		// 	) 
		// });
	}
*/
	
	// create the heatmap using random data
/*
	var startLat = 37.705;
	var startLng = -122.515;
	
	for (var i = 0; i < 125; i++) {
		for (var j = 0; j < 125; j++) {
			heatmapElevData.push({ 
				location: new google.maps.LatLng(
					startLat + i * .001, 
					startLng + j * .0013), 
					weight: (Math.random()
				) 
			});
		}
	}
*/

	// remember whether elevHeatmap is blue or green	
	var blueOrGreen;
	if (elevHeatmap && elevHeatmap.gradient) {
		blueOrGreen = gradient;
	} 
	
	// remove elevHeatmap before re-creating it so it doesn't darken upon button reclicks
	// may not need this any more if we remove button
	// keep button for now in case auto-load is too slow on live site
	if (elevHeatmap) { 
		elevHeatmap.setMap(null);
	}

	heatmapElevArray = new google.maps.MVCArray(heatmapElevData);

    elevHeatmap = new google.maps.visualization.HeatmapLayer({
	    data: heatmapElevArray,
		opacity: .6,
		maxIntensity: 2,
		dissipating: true,
		radius: influence,
		gradient: blueOrGreen
    });

    elevHeatmap.setMap(map);

	// show elevation using markers instead of heatmap
/*	
	var markers = 0;

	for (var i=0;i<dataArray.length;i+=3) {
		document.getElementById("test_output").innerHTML += '<br>maxElevation: ' + 
			maxElevation;
		var location = new google.maps.LatLng(dataArray[i], dataArray[i+1]);
		var elevation = parseFloat(dataArray[i+2]);
		var percentage = elevation / maxElevation;
		// elevation = "maxElevation";
		placeMarker(location, percentage);
		markers++;
	}
*/

} // end showElevations

function toggleHeatmap() {
	heatmap.setMap(heatmap.getMap() ? null : map2);
}

function changeGradient() {

	elevHeatmap.setOptions({
	    gradient: elevHeatmap.get('gradient') ? null : gradient
	});
}

function placeMarker(location, percentage) {

	var color = '#FF0000';
	var opacity = percentage;
	
	var marker = new google.maps.Marker({
		position: location,
		map: map,
		flat: true,
		icon: { 
			path: google.maps.SymbolPath.CIRCLE,
			scale: 20,
			fillOpacity: opacity,
			fillColor: color,
			strokeColor: color,
			strokeOpacity: opacity,
			strokeWeight: 1
		},
		title: percentage.toString()
	});
} // end placeMarker

// BELOW HERE IS STUFF NOT BEING USED
// KEPT FOR REFERENCE/LEARNING

// this function not active but still works to shade map in a coarse grid
// based on actively pulling elevation data for a few points from Google Elev API

var density;

function gatherElevations(event) {    
	var bounds = map.getBounds();
	//middle is vertical; center is horizontal
	var top, right, bottom, left, middle, center;

	var mapBottom = bounds.getSouthWest().lat();
	var mapLeft = bounds.getSouthWest().lng();
	var mapTop = bounds.getNorthEast().lat();
	var mapRight = bounds.getNorthEast().lng();

	var cubenumber = 0;
	var locations = [];

	for (var i=0; i<density; i++) {
		top = (mapTop - mapBottom)*((density-i)/density) + mapBottom;
		bottom = (mapTop - mapBottom)*((density-i-1)/density) + mapBottom;
		middle = (top - bottom)/2 + bottom;
		for (var j=0; j<density; j++) {
			left = (mapLeft - mapRight)*((density-j)/density) + mapRight;
			right = (mapLeft - mapRight)*((density-j-1)/density) + mapRight;
			center = (left - right)/2 + right;
		
			coordsZero = [
				new google.maps.LatLng(bottom, left),
				new google.maps.LatLng(top, left),
				new google.maps.LatLng(top, right),
				new google.maps.LatLng(bottom, right),
				new google.maps.LatLng(bottom, left)
			];
	
			cubes[cubenumber].setOptions({
				path: coordsZero,
				strokeColor: "#FF0000",
				strokeOpacity: .8,
			    strokeWeight: 1,
				fillColor: "#GG0000"
			});
			locations[cubenumber] = new google.maps.LatLng(middle, center);
			cubenumber++;
		}
	}
	
	var positionalRequest = { 'locations': locations }
	var elevations = [];
	var resolutions = [];
		

	elevator.getElevationForLocations(positionalRequest, function(results, status) {
		if (status == google.maps.ElevationStatus.OK) {
			// document.getElementById("test_output").innerHTML += '<br> status says OK';
			for (var i=0; i<density*density; i++) {
				elevations[i] = results[i].elevation;
				resolutions[i] = results[i].resolution;				
			}
		} else {
			document.getElementById("test_output").innerHTML += 'fuck me';
		}

		// have to put this stuff inside the callback function
		// otherwise it may get executed before the callback function finishes
		// and it needs to happen after bc it depends on stuff that happens in the callback
		var maxElevation = Math.max.apply(Math, elevations);
		var maxResolution = Math.max.apply(Math, resolutions);
		
		for (var i=0; i<density*density; i++) {
			elevations[i] = results[i].elevation;
			resolutions[i] = results[i].resolution;				
			cubes[i].setOptions({ 
				fillOpacity: (elevations[i]/maxElevation),
			});
		}
		
		// Ajax request sending elevations and locations to ruby file to write to a file
		// so all elevations requested through this method will be stored
		var xhr = new XMLHttpRequest();
		
		xhr.onreadystatechange = function() {
			if(xhr.readyState == 4) {
				// this is where we know we have completed the action
				// but don't want to do anything with what is returned
				// since this Ajax call is only to send info one-way from browser to server
			}
		}
		

		// using 'GET'
/*
		var testString = "test?"
		
		for (var i=0;i<5;i++) {
			testString += 	"&ele" + i + "=" + elevations[i] + 
							"&lat" + i + "=" + locations[i].lat() +
							"&lng" + i + "=" + locations[i].lng()
		}
		
		document.getElementById("test_output").innerHTML += "<br>" + testString;
		
		xhr.open("GET", testString, true);
		xhr.send();
*/
		
		// using 'POST' to overcome url size limit of 'GET'
		
		var postString = "";

		for (var i=0;i<36;i++) {
			postString += 	"&ele" + i + "=" + elevations[i] + 
							"&lat" + i + "=" + locations[i].lat() +
							"&lng" + i + "=" + locations[i].lng()
		}

		xhr.open("POST", 'test', true);
		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		xhr.send(postString);
		
	});
	
} // end gatherElevations


	// ADDITIONAL NOTES AND INSTRUCTIONS

	// HOW TO MAKE A CUSTOM CONTROL:	
/*
	var tokyoControlDiv = document.createElement('div');
	var tokyoControl = new TokyoControl(tokyoControlDiv, map);

	tokyoControlDiv.index = 1;
	map.controls[google.maps.ControlPosition.TOP_RIGHT].
		push(tokyoControlDiv);
*/

/*
	function TokyoControl(controlDiv, map) {
		controlDiv.style.padding = '5px';
	
		var controlUI = document.createElement('div');
	
		controlUI.style.backgroundColor = 'white';
		controlUI.style.borderStyle = 'solid';
		controlUI.style.borderWidth = '2px';
		controlUI.style.cursor = 'pointer';
		controlUI.style.textAlign = 'center';
		controlUI.title = 'Click to return to Tokyo';
	
		controlDiv.appendChild(controlUI);
	
		var controlText = document.createElement('div');

		controlText.style.fontFamily = 'Arial,sans-serif';
		controlText.style.fontSize = '12px';
		controlText.style.paddingLeft = '4px';
		controlText.style.paddingRight = '4px';
		controlText.innerHTML = '<strong>Tokyo</strong>';

		controlUI.appendChild(controlText);
	
		// apparently, listening to custom controls requires 
		// listening to the DOM, even though listening to markers
		// can be done w/ just a Listener, i.e. w/o a DomListener
		google.maps.event.addDomListener(controlUI, 'click', function() {
			map.setCenter(new google.maps.LatLng(35.6833, 139.7667))
		});
	
	} // end TokyoControl
*/

	// HOW TO SET A MARKER:
/*
	var marker = new google.maps.Marker({
		position: new google.maps.LatLng(37.780, -122.430),
		map: map2,
		title: map.getCenter().toString()
	});
*/

	// COOL WAY TO TOGGLE MAP FEATURES:
/*
	function changeRadius() {
		heatmap.setOptions({radius: heatmap.get('radius') ? null : 20});
	}
*/

	// HOW TO SET AN INFOWINDOW:
/*
	infowindow.setContent("lat: " + northerly.lat());
	infowindow.setPosition(myLatLong);
	infowindow.open(map);
*/

	// HOW TO DO A DELAYED ACTION:
/*
	google.maps.event.addListener(map, 'center_changed', function() {
		
		// map moves back to original center 3 secs after map moves away
		window.setTimeout(function () {
			map.panTo(marker.getPosition());
		}, 3000);
	});
*/

	// HOW TO SPECIFY A FUNCTION WHILE SETTING A LISTENER
/*
	google.maps.event.addListener(map, 'zoom_changed', function() {
		// have to call getProperty on the object b/c MVC state change
		// events do not pass arguments/properties with the objects
		var zoomLevel = map.getZoom();
		map.setCenter(myLatLong);
		infowindow.setContent('Zoom: ' + zoomLevel);
	});
*/
	
	// HOW TO SET A LISTENER WITHOUT SPECIFYING A FUNCTION
/*
	google.maps.event.addListener(map, 'click', postElevation);
*/

/*
function postElevation(event) {
	
	var locations = [];
	
	var clickLoc = event.latLng;
	locations.push(clickLoc);
	
	var positionalRequest = { 'locations': locations }
	
	elevator.getElevationForLocations(positionalRequest, function(results, status) {
		if (status == google.maps.ElevationStatus.OK) {
			infowindow.setContent("Elev is: " + results[0].elevation);
			infowindow.setPosition(clickLoc);
		} else {
			infowindow.setContent("Fuck me");
			infowindow.setPosition(clickLoc);
		}
	});
	
} // end postElevation
*/


