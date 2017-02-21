require 'sass/plugin/rack'
require 'fileutils'
require 'letsencrypt_rack'
require './compile_src'

use Sass::Plugin::Rack
use CompileSrc
use LetsencryptRack::Middleware
use Rack::Static, urls: %w(/images /js /stylesheets), root: 'public'

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}
