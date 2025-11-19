source 'https://rubygems.org'

ruby File.read("#{__dir__}/.tool-versions")[/ruby \K.+/] || fail

gem 'rack'
gem 'rackup'
gem 'puma'
gem 'sass'
gem 'letsencrypt_rack'

group :development do
  gem 'letsencrypt_heroku'
end
