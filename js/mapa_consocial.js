$(function() {
  // Centraliza o mapa no Brasil
  var latlng = new google.maps.LatLng(-14.221789, -51.943359);

  var opcoes = {
    zoom: 5,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  window.map = new google.maps.Map($('#map_canvas')[0], opcoes);
  window.infoWindow = new google.maps.InfoWindow()

  function attachClickEvent(marker) {
    google.maps.event.addListener(marker, 'click', function() {
      window.infoWindow.setContent(marker.content);
      window.infoWindow.open(window.map, marker);
    });
  }

  $.getJSON('pontos.json', function(data) {
    if (data) {
      var i, item, marker, latlng, c;
      for (i = 0; i < data.length; i++) {
        item = data[i];

        if (!item.lat || !item.lng) {
          continue;
        }

        latlng = new google.maps.LatLng(item.lat, item.lng);

        marker = new google.maps.Marker({
          map: window.map,
          position: latlng,
          title: item.titulo
        });

        marker.content = "<h1>" + item.titulo + "</h1>";
        marker.content += "<ul>";

        for (c = 0; c < item.campos.length; c++) {
          for (var key in item.campos[c]) {
            marker.content += "<li><strong>" + key + "</strong>: " + item.campos[c][key];
          }
        }

        marker.content += "</ul>";

        attachClickEvent(marker);
      }
    }
  });
});
