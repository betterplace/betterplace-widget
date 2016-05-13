workers Integer(ENV['WEB_CONCURRENCY'] || 5)
threads_count = Integer(ENV['MAX_THREADS'] || 32)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT'] || 9292
