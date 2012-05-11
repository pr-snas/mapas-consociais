$(function() {
  // Centraliza o mapa no Brasil
  var latlng = new google.maps.LatLng(-14.221789, -51.943359);

  var opcoes = {
    zoom: 5,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  window.mapa = new google.maps.Map($('#map_canvas')[0], opcoes);

  $.getJSON('pontos.json', function(data) {
    console.log(data);
    return

    if (data) {
      var i, item, marker;
      for (i = 0; i < data.length; i++) {
        item = data[i];
        marker = new google.maps.Marker({
          map: window.mapa,
          position: false,
          title: ""
        });
        window.markers.push(marker);
      }
    }
  });
});
