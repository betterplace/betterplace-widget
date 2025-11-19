require 'sass/plugin/rack'
require 'fileutils'
require 'letsencrypt_rack'
require './compile_src'
require 'rack/static'

use Sass::Plugin::Rack
use CompileSrc
use LetsencryptRack::Middleware
use Rack::Static, urls: %w[/images /js /stylesheets], root: 'public'

run lambda { |_env|
  [
    200,
    {
      'content-type'  => 'text/html',
      'cache-control' => 'public, max-age=86400'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}
