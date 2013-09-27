// This is a manifest file that'll be compiled into application.js, which will
// include all the files listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
// vendor/assets/javascripts, or vendor/assets/javascripts of plugins, if any,
// can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at
// the bottom of the the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY
// BLANK LINE SHOULD GO AFTER THE REQUIRES BELOW.
//
// Default
//= require jquery
//= require jquery_ujs
// Libraries
//= require twitter/bootstrap
//= require underscore
//= require backbone
//= require handlebars.runtime
//= require sugar
//= require kalendae
//= require waypoints
//
// URI.js
//= require uri.js/IPv6
//= require uri.js/punycode
//= require uri.js/SecondLevelDomains
//= require uri.js/URI
//
// Backbone-Specific
//= require backbone-relational
//= require bootstrap-wysihtml5
//= require backbone-forms
//
//= require .//showgap
//
// Helpers must be loaded before mixins since some mixins are duplicate
// helpers.
//= require_tree .//helpers
//= require_tree .//mixins
//= require_tree ../templates/
//= require_tree .//models
//= require_tree .//collections
//= require_tree .//views
//= require_tree .//routers
//
// Must be loaded after JST is defined (when loading ../templates)
//= require backbone_forms_template
