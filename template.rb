@bower_packages = [['select2', '4.0.3'], ['lodash', '4.16.6']]
@monitoring_enabled = false
@carrierwave_enabled = false

path = if File.exists? @rails_template
          File.dirname(@rails_template)
        else
          @tmp_dir = Dir.mktmpdir
          run "git clone -b 'feature/modularize' git@github.com:MarsBased/pathfinder.git #{@tmp_dir}"
          @tmp_dir
        end

require(File.join(path, 'pathfinder'))
Pathfinder.new(self).call







# def template_local
#   @template_local ||= File.exists? @rails_template
# end
#
# def template_path
#   @template_path ||= if @template_local
#                         File.dirname(@rails_template)
#                      else
#                        @rails_template[/^(.*)\/.*\.rb/, 1]
#                      end
# end
#
# def clean_tmp
#   return if template_local
#   @imported_files.each { |f| File.delete(File.join(TMP_DIR, "#{f}.rb")) }
# end
#
# def import_file(filename)
#   require_relative(filename) if template_local
#   (@imported_files ||= []) << filename
#   run "wget -q #{File.join(template_path, filename)}.rb -P #{TMP_DIR}"
#   require(File.join(TMP_DIR, filename))
# end
#
# import_file('utils')
# @utils = Utils.new(self)
#
# def configure_rollbar
#   initializer 'rollbar.rb', <<-CODE
# Rollbar.configure do |config|
#   config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
#   config.environment = ENV['ROLLBAR_ENV'] || Rails.env
#   config.exception_level_filters.merge!(
#     'ActionController::RoutingError': 'ignore'
#   )
#
#   if Rails.env.test? || Rails.env.development?
#     config.enabled = false
#   end
# end
#   CODE
#
#   inside 'config' do
#     append_file 'application.yml.example', "\nROLLBAR_ACCESS_TOKEN: ''"
#     append_file 'application.yml', "\nROLLBAR_ACCESS_TOKEN: ''"
#   end
# end
#
# def configure_airbrake
#   initializer 'airbrake.rb', <<-CODE
# Airbrake.configure do |config|
#   config.api_key = ENV['AIRBRAKE_API_KEY']
# end
#   CODE
#
#   inside 'config' do
#     append_file 'application.yml.example', "\nAIRBRAKE_API_KEY: ''"
#     append_file 'application.yml', "\nAIRBRAKE_API_KEY: ''"
#   end
# end
#
# def configure_database
#   inside 'config' do
#     remove_file 'database.yml'
#     create_file 'database.yml' do <<-EOF
# default: &default
#   adapter: postgresql
#   encoding: unicode
#   pool: 5
#
# development:
#   <<: *default
#   database: #{app_name}_development
#
# staging:
#   <<: *default
#   database: #{app_name}_staging
#   username: #{app_name}
#   password: <%= ENV['#{app_name.upcase}_DATABASE_PASSWORD'] %>
#
# test:
#   <<: *default
#   database: #{app_name}_test
#
# production:
#   <<: *default
#   database: #{app_name}_production
#   username: #{app_name}
#   password: <%= ENV['#{app_name.upcase}_DATABASE_PASSWORD'] %>
#
#   EOF
#     end
#     append_file 'application.yml.example', "\n#{app_name.upcase}_DATABASE_PASSWORD: ''"
#     append_file 'application.yml', "\n#{app_name.upcase}_DATABASE_PASSWORD: ''"
#   end
#   rake 'db:create'
# end
#
# def configure_redis
#   initializer 'redis.rb', <<-CODE
# Redis.current = Redis.new(Rails.application.config_for(:redis))
#   CODE
#
#   inside 'config' do
#     create_file 'redis.yml' do <<-EOF
# default: &default
#   host: localhost
#   port: 6379
#
# development:
#   <<: *default
# test:
#   <<: *default
#     EOF
#     end
#   end
# end
#
# def configure_sidekiq
#   initializer 'sidekiq.rb', <<-CODE
# redis_host = Redis.current.client.host
# redis_port = Redis.current.client.port
#
# Sidekiq.configure_server do |config|
#   config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
# end
#   CODE
#
#   inside 'config' do
#     create_file 'sidekiq.yml' do <<-EOF
# ---
# :concurrency: 5
# :pidfile: tmp/pids/sidekiq.pid
# staging:
#   :concurrency: 10
# production:
#   :concurrency: 20
# :queues:
#   - [default, 10]
#   - [mailers, 10]
#     EOF
#     end
#   end
#
#   insert_into_file 'config/routes.rb', before: "Rails.application.routes.draw do\n" do <<-RUBY
# require 'sidekiq/web'
#   RUBY
#   end
#
#   insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-RUBY
#   namespace :admin do
#     authenticate :user, lambda { |u| u.admin? } do
#       mount Sidekiq::Web => '/sidekiq'
#     end
#   end
#   get '/404', to: 'errors#not_found'
#   get '/500', to: 'errors#internal_error'
#   RUBY
#   end
# end
#
# def configure_gitignore
#   remove_file '.gitignore'
#   create_file '.gitignore' do <<-EOF
# !/log/.keep
# *.rdb
# .bundle
# config/application.yml
# config/database.yml
# config/secrets.yml
# config/secrets.*.yml
# log/*
# public/assets
# public/uploads
# tmp
# .DS_Store
# *.sublime-*
# .rvmrc
# stellar.yml
# .rubocop.yml
#
# # Ignore generated coverage
# /coverage
#
# # Bower stuff
# vendor/assets/.bowerrc
# vendor/assets/bower.json
# vendor/assets/bower_components
#   EOF
#   end
# end
#
# def configure_bower_resources(bower_resources = [])
#   remove_file 'bower.json'
#   create_file 'bower.json' do <<-TEXT
# {
#   "lib": {
#     "name": "bower-rails generated lib assets",
#     "dependencies": { }
#   },
#   "vendor": {
#     "name": "bower-rails generated vendor assets",
#     "dependencies": {
#   TEXT
#   end
#
#
#   packages = bower_resources.map { |package, version| "\"#{package}\": \"#{version}\"" }
#                             .join(",\n")
#
#   append_file 'bower.json', "#{packages}\n" unless packages.empty?
#   append_file 'bower.json' do <<-TEXT
#     }
#   }
# }
#   TEXT
#   end
# end
#
# def configure_carrierwave
#   initializer 'carrierwave.rb', <<-CODE
#   require 'carrierwave/storage/fog'
# CarrierWave.configure do |config|
#   config.fog_provider = 'fog/aws'
#   config.fog_directory = ENV['AWS_S3_BUCKET']
#   config.fog_public = true
#   config.storage = :fog
#   config.cache_dir = Rails.root.join('tmp/cache')
#
#   config.fog_credentials = {
#     provider: 'AWS',
#     aws_access_key_id: ENV['AWS_ACCESS_KEY'],
#     aws_secret_access_key: ENV['AWS_SECRET_KEY'],
#     region: 'eu-west-1'
#   }
# end
#   CODE
#
#   inside 'config' do
#     append_file 'application.yml.example', "\nAWS_ACCESS_KEY: ''"
#     append_file 'application.yml', "\nAWS_ACCESS_KEY: ''"
#     append_file 'application.yml.example', "\nAWS_SECRET_KEY: ''"
#     append_file 'application.yml', "\nAWS_SECRET_KEY: ''"
#     append_file 'application.yml.example', "\nAWS_S3_BUCKET: ''"
#     append_file 'application.yml', "\nAWS_S3_BUCKET: ''"
#   end
# end
