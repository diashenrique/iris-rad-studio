var urlOrigin = window.location.origin;
var urlREST = urlOrigin + "/csp/irisapp/api";

$(document).ready(function () {

  $.getJSON(urlREST + "/sql/list", function(response) {
    
    $("#datatable-1").DataTable({
        responsive: true,
        data: response
    });

  });
 
});