(function($){  
  $.fn.googleMap = function(address, options) {  
    var opts = $.extend($.fn.googleMap.defaults, options);
    return this.each(function() {  
      warn("calling geometry for " + this.id);
      var elem = this;  // create alias to be captured in callback closure- 'this' will be overridden
      new google.maps.Geocoder().geocode( { 'address': $(this).metadata().address }, function(results,status) {
        warn("geocode result for " + elem.id);
        if (status == google.maps.GeocoderStatus.OK) {     
          var loc =  results[0].geometry.location;
          var map = new google.maps.Map(elem, $.extend(opts,{ center: loc }));
          var marker = new google.maps.Marker({ map: map, position: loc });
        } else {
          $(elem).html(      
            'Oops, "' + address + '" isnt a valid address' + 
            '<div class="faint">Geocode was not successful for the following reason: ' + 
              status + '</div>'
          );
        }
      });
    });  
  };

  $.fn.googleMap.defaults = {
    zoom: 8,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

})(jQuery);
      