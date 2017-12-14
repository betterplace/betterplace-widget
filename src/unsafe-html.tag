riot.tag('unsafe-html', '', function(opts) {
  var set = function() { this.root.innerHTML = opts.html || '...' }.bind(this)
  this.on('update', set)
  this.on('mount', set)
})
