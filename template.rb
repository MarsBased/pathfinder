

def template_local
  @template_local ||= File.exists? @rails_template
end

def template_path
  @template_path ||= if @template_local
                        File.dirname(@rails_template)
                     else
                       puts @rails_template
                       puts @options[:template]
                        # @rails_template[/^(.*)\/.*\.rb/, 1] << '/utils.rb'
                     end
end

def clean_tmp
  return if template_local
end

def import_file(filename)
  require_relative(filename) if template_local

end

puts template_path
import_file('utils')

puts @rails_template
puts template_path

require_relative "utils"

@bower_packages = [['select2', '4.0.3'], ['lodash', '4.16.6']]
@monitoring_enabled = false
@carrierwave_enabled = false

def configure_rollbar
  initializer 'rollbar.rb', <<-CODE
Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.environment = ENV['ROLLBAR_ENV'] || Rails.env
  config.exception_level_filters.merge!(
    'ActionController::RoutingError': 'ignore'
  )

  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  end
end
  CODE

  inside 'config' do
    append_file 'application.yml.example', "\nROLLBAR_ACCESS_TOKEN: ''"
    append_file 'application.yml', "\nROLLBAR_ACCESS_TOKEN: ''"
  end
end

def configure_airbrake
  initializer 'airbrake.rb', <<-CODE
Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
end
  CODE

  inside 'config' do
    append_file 'application.yml.example', "\nAIRBRAKE_API_KEY: ''"
    append_file 'application.yml', "\nAIRBRAKE_API_KEY: ''"
  end
end

def configure_database
  inside 'config' do
    remove_file 'database.yml'
    create_file 'database.yml' do <<-EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5

development:
  <<: *default
  database: #{app_name}_development

staging:
  <<: *default
  database: #{app_name}_staging
  username: #{app_name}
  password: <%= ENV['#{app_name.upcase}_DATABASE_PASSWORD'] %>

test:
  <<: *default
  database: #{app_name}_test

production:
  <<: *default
  database: #{app_name}_production
  username: #{app_name}
  password: <%= ENV['#{app_name.upcase}_DATABASE_PASSWORD'] %>

  EOF
    end
    append_file 'application.yml.example', "\n#{app_name.upcase}_DATABASE_PASSWORD: ''"
    append_file 'application.yml', "\n#{app_name.upcase}_DATABASE_PASSWORD: ''"
  end
  rake 'db:create'
end

def configure_redis
  initializer 'redis.rb', <<-CODE
Redis.current = Redis.new(Rails.application.config_for(:redis))
  CODE

  inside 'config' do
    create_file 'redis.yml' do <<-EOF
default: &default
  host: localhost
  port: 6379

development:
  <<: *default
test:
  <<: *default
    EOF
    end
  end
end

def configure_sidekiq
  initializer 'sidekiq.rb', <<-CODE
redis_host = Redis.current.client.host
redis_port = Redis.current.client.port

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
end
  CODE

  inside 'config' do
    create_file 'sidekiq.yml' do <<-EOF
---
:concurrency: 5
:pidfile: tmp/pids/sidekiq.pid
staging:
  :concurrency: 10
production:
  :concurrency: 20
:queues:
  - [default, 10]
  - [mailers, 10]
    EOF
    end
  end

  insert_into_file 'config/routes.rb', before: "Rails.application.routes.draw do\n" do <<-RUBY
require 'sidekiq/web'
  RUBY
  end

  insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-RUBY
  namespace :admin do
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end
  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'
  RUBY
  end
end

def configure_gitignore
  remove_file '.gitignore'
  create_file '.gitignore' do <<-EOF
!/log/.keep
*.rdb
.bundle
config/application.yml
config/database.yml
config/secrets.yml
config/secrets.*.yml
log/*
public/assets
public/uploads
tmp
.DS_Store
*.sublime-*
.rvmrc
stellar.yml
.rubocop.yml

# Ignore generated coverage
/coverage

# Bower stuff
vendor/assets/.bowerrc
vendor/assets/bower.json
vendor/assets/bower_components
  EOF
  end
end

def configure_bower_resources(bower_resources = [])
  remove_file 'bower.json'
  create_file 'bower.json' do <<-TEXT
{
  "lib": {
    "name": "bower-rails generated lib assets",
    "dependencies": { }
  },
  "vendor": {
    "name": "bower-rails generated vendor assets",
    "dependencies": {
  TEXT
  end


  packages = bower_resources.map { |package, version| "\"#{package}\": \"#{version}\"" }
                            .join(",\n")

  append_file 'bower.json', "#{packages}\n" unless packages.empty?
  append_file 'bower.json' do <<-TEXT
    }
  }
}
  TEXT
  end
end

def configure_carrierwave
  initializer 'carrierwave.rb', <<-CODE
  require 'carrierwave/storage/fog'
CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_directory = ENV['AWS_S3_BUCKET']
  config.fog_public = true
  config.storage = :fog
  config.cache_dir = Rails.root.join('tmp/cache')

  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['AWS_ACCESS_KEY'],
    aws_secret_access_key: ENV['AWS_SECRET_KEY'],
    region: 'eu-west-1'
  }
end
  CODE

  inside 'config' do
    append_file 'application.yml.example', "\nAWS_ACCESS_KEY: ''"
    append_file 'application.yml', "\nAWS_ACCESS_KEY: ''"
    append_file 'application.yml.example', "\nAWS_SECRET_KEY: ''"
    append_file 'application.yml', "\nAWS_SECRET_KEY: ''"
    append_file 'application.yml.example', "\nAWS_S3_BUCKET: ''"
    append_file 'application.yml', "\nAWS_S3_BUCKET: ''"
  end
end


remove_file 'Gemfile'
run 'touch Gemfile'
add_source 'https://rubygems.org'

append_file 'Gemfile', "ruby \'#{ask_with_default('Which version of ruby do you want to use?', default: RUBY_VERSION)}\'"

gem 'rails', ask_with_default('Which version of rails do you want to use?', default: '4.2.5')

# DB
gem 'pg'

# User Management
gem 'devise'
gem 'pundit'

# Model
gem 'aasm'
gem 'keynote'
gem 'paranoia'

# Forms
gem 'simple_form'

# Searchs
gem 'ransack' if yes?("Do you want to use Ransack?")
gem 'kaminari'
gem 'searchkick' if yes?("Are you going to use ElasticSearch?")

# Assets
gem 'bootstrap-sass', '~> 3.3.3'
gem 'bootstrap-datepicker-rails', '~> 1.6.0' if yes?("Do you want to use Bootstrap datepicker?")
gem 'font-awesome-sass', '~> 4.3.0'
gem 'sass-rails', '~> 5.0'
gem 'modernizr-rails'
gem 'autoprefixer-rails'
gem 'compass-rails', '~> 3.0.1'
gem 'magnific-popup-rails'
gem 'jquery-rails'
gem 'uglifier', '>= 1.3.0'
gem 'sdoc', '~> 0.4.0', group: :doc
# Assets
gem 'bower-rails'

# Jobs
gem 'redis'
gem 'sidekiq'
gem 'sinatra', require: nil

# File uploads
if yes?("Do you want to use Carrierwave?")
  @carrierwave_enabled = true
  gem 'carrierwave'
  gem 'fog-aws'
  gem 'mini_magick' if yes?("Are you going to handle images?")
end


# Monitoring
case ask('Choose Monitoring Engine:', limited_to: %w(rollbar airbrake none))
when 'rollbar'
  gem 'rollbar'
  @monitoring_enabled = :rollbar
when 'airbrake'
  gem 'airbrake'
  @monitoring_enabled = :airbrake
else
end

# Emails
gem 'premailer-rails'

gem_group :development, :test do
  gem 'bundler-audit', require: false
  gem 'byebug'
  gem 'rspec-rails'
  gem 'spring'
  gem 'quiet_assets'
  gem 'figaro'
  gem 'mailcatcher'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

gem_group :development do
  gem 'spring-commands-rspec', require: false
  gem 'better_errors'
end

gem_group :test do
  gem 'simplecov', require: false
  gem 'capybara', require: false
  gem 'capybara-webkit', require: false
  gem 'database_cleaner', require: false
  gem 'fakeredis', require: false
  gem 'poltergeist', require: false
  gem 'shoulda-matchers', require: false
end

after_bundle do
  run 'spring stop'

  inside 'config' do
    create_file 'application.yml'
    create_file 'application.yml.example'
    remove_file 'routes.rb'
    create_file 'routes.rb' do <<-RUBY
Rails.application.routes.draw do
end
    RUBY
    end
  end

  configure_database
  configure_carrierwave if @carrierwave_enabled

  generate 'rspec:install'

  generate 'simple_form:install'
  generate 'pundit:install'
  insert_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-RUBY
  include Pundit
  RUBY
  end

  generate 'devise:install'
  insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do  <<-RUBY
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_controller.asset_host = 'http://localhost:3000'
  config.action_mailer.asset_host = 'http://localhost:3000'
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
  RUBY
  end

  configure_rollbar if @monitoring_enabled == :rollbar
  configure_airbrake if @monitoring_enabled == :airbrake
  configure_redis
  configure_sidekiq
  configure_gitignore


  run 'rails g bower_rails:initialize json'
  configure_bower_resources @bower_packages
  rake 'bower:install'
  rake 'bower:resolve'

  clean_tmp
end
