// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap-sprockets
//= require rails-ujs
//= require activestorage
//= require_tree .

$(document).ready(function() {
  // Initialize datepickers
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd'
  });

  // Dynamic line items
  $(document).on('click', '.add-line-item', function(e) {
    e.preventDefault();
    var template = $('.line-item-template').html();
    var timestamp = new Date().getTime();
    template = template.replace(/NEW_RECORD/g, timestamp);
    $('.line-items-container').append(template);
  });

  $(document).on('click', '.remove-line-item', function(e) {
    e.preventDefault();
    var container = $(this).closest('.line-item-row');
    container.find('input[name*="_destroy"]').val('1');
    container.hide();
  });
});
