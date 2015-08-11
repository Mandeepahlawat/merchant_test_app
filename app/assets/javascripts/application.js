// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require turbolinks
//= require bootstrap-multiselect
//= require bootstrap-slider
//= require bootstrap-typeahead-rails
//= require_tree .

$(document).ready(function() {
  $('.mutiple-select').multiselect({
  	onChange: function(option, checked, select) {
      option.closest(".search").submit();
  	}
  });

  $("#ratings-filter").slider({
    ticks: [0, 1, 2, 3, 4, 5],
    ticks_labels: ['0', '1', '2', '3', '4', '5'],
    ticks_snap_bounds: 3
	}).on('slideStop', function(ev){
    $(this).closest(".search").submit();
  });

  $("#price-filter").slider().on('slideStop', function(ev){
    $(this).closest(".search").submit();
  });

  $("#session-filter").slider().on('slideStop', function(ev){
    $(this).closest(".search").submit();
  });

});

$(document).on("click", ".sort-link", function(e){
  e.preventDefault();
  var sort_order = $(this).data("sort-order");
  $("#sort-order-input").val(sort_order);
  $(".search").submit();
})

$(document).on("click",".search input",function(){
  $(this).closest(".search").submit();
});