// TODO: Why doesn't the shim correctly get the jsyaml reference?
define(['require', 'text', 'js-yaml'], function(require, text) {
return {
  load: function(name, require, onload, config) {
    text.get(
      require.toUrl(name),
      function(data) {
          onload(jsyaml.load(data));
        },
      onload.error
    );
  }
}
});