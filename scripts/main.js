// TODO: Avoid referring directly to bower_components here.
require.config({
  packages: [
    {
      name: 'cs',
      location: '../bower_components/require-cs',
      main: 'cs'
    },
    {
      name: 'coffee-script',
      location: '../bower_components/coffee-script',
      main: 'index'
    },
    {
      name: 'css',
      location: '../bower_components/require-css',
      main: 'css'
    },
    {
      name: 'less',
      location: '../bower_components/require-less',
      main: 'less'
    }
  ],
  paths: {
    backbone: '../bower_components/backbone/backbone',
    underscore: '../bower_components/underscore/underscore',
    jquery: '../bower_components/jquery/jquery',
    marionette: '../bower_components/marionette/lib/backbone.marionette',
    handlebars: '../bower_components/handlebars/handlebars',
    'backbone.mutators': '../bower_components/backbone.mutators/backbone.mutators',
    // for require-handlebars-plugin
    hbs: '../bower_components/require-handlebars-plugin/hbs',
    i18nprecompile: '../bower_components/require-handlebars-plugin/hbs/i18nprecompile',
    json2: '../bower_components/require-handlebars-plugin/hbs/json2'
  },
  shim: {
    jquery: {
      exports: 'jQuery'
    },
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: [ 'jquery', 'underscore' ],
      exports: 'Backbone'
    },
    marionette: {
      deps: [ 'jquery', 'underscore', 'backbone' ],
      exports: 'Marionette'
    },
    handlebars: {
      exports: 'Handlebars'
    }
  },
  hbs: {
    disableI18n: true,
    templateExtension: 'handlebars'
  }
});

require([ 'cs!app/app' ], function(main) {
  main();
});
