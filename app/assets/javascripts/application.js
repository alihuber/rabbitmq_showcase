// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .

$(document).ready(function() {
//   setInterval(function() {
//     return $.get("/smoke_test_ajax_progress", function(response) {
//       return $("#working-queue").replaceWith(response);
//     });
//   }, 2000)

//   setInterval(function() {
//     return $.get("/topic_ajax_progress", function(response) {
//       return $("#working-queue-topics").replaceWith(response);
//     });
//   }, 2000)

//   setInterval(function() {
//     return $.get("/worker_ajax_progress", function(response) {
//       return $("#working-queue-worker").replaceWith(response);
//     });
//   }, 2000)

//   setInterval(function() {
//     return $.get("/workflow_ajax_progress", function(response) {
//       return $("#working-queue-workflow").replaceWith(response);
//     });
//   }, 2000)

  setInterval(function() {
    return $.get("/pdf_ajax_progress", function(response) {
      return $("#pdf-working-queue").replaceWith(response);
    });
  }, 500)

  $("#fetch_pdfs").click(function() {
    var count = $("#pdf_count").val();
    $("#fetch_pdfs").attr("name", count);
  });
});
