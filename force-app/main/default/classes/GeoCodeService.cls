public with sharing class GeoCodeService {
    
    public with sharing class GeocodeService {

    // Method to geocode a single address
    @future(callout=true)
    public static GeocodeResult geocodeAddress(String address) {
        GeocodeResult result = new GeocodeResult();
        if (String.isBlank(address)) {
            result.error = 'Address cannot be blank.';
            return result;
        }

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&key=YOUR_GOOGLE_MAPS_API_KEY');
            req.setMethod('GET');
            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> resultsList = (List<Object>) results.get('results');

                if (resultsList != null && !resultsList.isEmpty()) {
                    Map<String, Object> firstResult = (Map<String, Object>) resultsList.get(0);
                    Map<String, Object> geometry = (Map<String, Object>) firstResult.get('geometry');
                    Map<String, Object> location = (Map<String, Object>) geometry.get('location');

                    result.latitude = String.valueOf(location.get('lat'));
                    result.longitude = String.valueOf(location.get('lng'));
                    result.formattedAddress = (String) firstResult.get('formatted_address');
                    result.success = true;
                } else {
                    result.error = 'No results found for the address.';
                }
            } else {
                result.error = 'Callout failed with status code: ' + res.getStatusCode();
            }

        } catch (Exception e) {
            result.error = 'Error during geocoding: ' + e.getMessage();
        }

        return result;
    }

    public class GeocodeResult {
        public String latitude {get; set;}
        public String longitude {get; set;}
        public String formattedAddress {get; set;}
        public String error {get; set;}
        public Boolean success {get; set;}
    }
}
}