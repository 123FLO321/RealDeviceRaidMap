<?php

// ↓ Edit me! ↓

$DB_TYPE = "mysql"; // "mysql" or "pgsql"
$DB_HOST = "localhost";
$DB_USER = "root";
$DB_PSWD = "";
$DB_NAME = "monocledb";
$DB_PORT = 3306;

$MIN_LAT = -90;
$MAX_LAT = +90;
$MIN_LON = -180;
$MAX_LON = +180;

$DELAY = 5;
$GYM_COUNT = 6;
$TRY_COUNT = 100;
$ROUTE_NAME = "Route1";


// ↓ Don't touch me!↓

$db = null;
if ($DB_TYPE == "mysql") {
	$db = new mysqli($DB_HOST, $DB_USER, $DB_PSWD, $DB_NAME, $DB_PORT);
	if ($db->connect_error != '') {
		exit("Failed to connect to MySQL server!");
	}
	$db->set_charset('utf8');
} else if ($DB_TYPE == "pgsql") {
	$db = pg_connect("host=".$DB_HOST." port=".$DB_PORT." dbname=".$DB_NAME." user=".$DB_USER." password=".$DB_PSWD);
	if ($db === false) {
		exit("Failed to connect to PostgreSQL server!");
	}
} else {
	exit("Wrong DB_TYPE!");
}


function haversineGreatCircleDistance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo, $earthRadius = 6371000) {
	// convert from degrees to radians
	$latFrom = deg2rad($latitudeFrom);
	$lonFrom = deg2rad($longitudeFrom);
	$latTo = deg2rad($latitudeTo);
	$lonTo = deg2rad($longitudeTo);

	$latDelta = $latTo - $latFrom;
	$lonDelta = $lonTo - $lonFrom;

	$angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
			cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
	return $angle * $earthRadius;
}

$gyms = array();

if ($DB_TYPE == "mysql") {
	$req = "SELECT lat as latitude, lon as longitude, name
			FROM forts
			WHERE lat >= ".$MIN_LAT." AND lat <= ".$MAX_LAT." AND lon >= ".$MIN_LON." AND lon <= ".$MAX_LON;
	$result = $db->query($req);
	$i = 0;
	while ($data = $result->fetch_object()) {
		$gyms[$i] = $data;
		$i ++;
	}
} else {
	$req = "SELECT lat as latitude, lon as longitude, name
			FROM forts
			WHERE lat >= ".$MIN_LAT." AND lat <= ".$MAX_LAT." AND lon >= ".$MIN_LON." AND lon <= ".$MAX_LON;
	$result = pg_query($db, $req);
	$i = 0;
	while ($data = pg_fetch_object($result)) {
		$gyms[$i] = $data;
		$i ++;
	}
}

print "Got ".sizeof($gyms)." Gyms!\n";

$locationsBest = array();
$tryCount = 1;
foreach(range(1,$TRY_COUNT) as $i) {

	shuffle($gyms);

	$workGyms = $gyms;
	$locations = array();

	while (sizeof($workGyms) != 0) {

		$gym = reset($workGyms);
		$index = key($workGyms);

		unset($workGyms[$index]);

		$clossestGyms = array();
		foreach ($workGyms as $index2 => $gym2) {
			$gym2->index = $index2;
			$dist = haversineGreatCircleDistance($gym->latitude, $gym->longitude, $gym2->latitude, $gym2->longitude);
			if ($dist <= 700) {
				if (sizeof($clossestGyms) < $GYM_COUNT - 1) {
					while (isset($clossestGyms[$dist])) {
						$dist += 1;
					}
					$clossestGyms[$dist] = $gym2;
				} else {
					krsort($clossestGyms);
					$keys = array_keys($clossestGyms);
					$last = end($keys);
					if ($dist <= $last) {

						while (isset($clossestGyms[$dist])) {
							$dist += 1;
						}
						array_pop($clossestGyms);
						$clossestGyms[$dist] = $gym2;
					}
				}
			}
		}

		foreach ($clossestGyms as $gym2) {
			unset($workGyms[$gym2->index]);
		}

		$locations[] = array(
			"latitude" => $gym->latitude,
			"longitude" => $gym->longitude,
		);
	}

	print "Try ".$tryCount." out of ". $TRY_COUNT. " found ".sizeof($locations)." Points\n";
	$tryCount++;

	if (sizeof($locationsBest) == 0 || sizeof($locationsBest) > sizeof($locations)) {
		$locationsBest = $locations;
	}

}

$sizeGyms = sizeof($gyms);
$sizePoints = sizeof($locationsBest);
$efficiency = ($sizeGyms/$sizePoints) / ($sizeGyms/($sizeGyms/$GYM_COUNT)) * 100;
print "Mapped ".$sizeGyms. " Gyms to ".$sizePoints." Points (Efficiency: ".number_format($efficiency,2)."%)\n";


$fileContents = "";
foreach ($locationsBest as $location) {
	$fileContents .= $location["latitude"].",".$location["longitude"].",".$DELAY."\n";
}

file_put_contents("Routes/".$ROUTE_NAME.".csv", $fileContents);
