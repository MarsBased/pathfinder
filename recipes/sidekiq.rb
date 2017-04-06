module Recipes
  class Sidekiq < Base

    def gems
      @template.gem 'sidekiq'
      @template.gem 'sinatra', require: nil
    end

    def init_file
      add_initializer
      add_configuration
      add_sidekiq_web
      set_job_queue
    end

    private

    def add_initializer
      @template.initializer 'sidekiq.rb', <<~CODE
        redis_host = Redis.current.client.host
        redis_port = Redis.current.client.port

        Sidekiq.configure_server do |config|
          config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
        end

        Sidekiq.configure_client do |config|
          config.redis = { url: "redis://\#{redis_host}:\#{redis_port}" }
        end
      CODE
    end

    def add_configuration
      @template.inside 'config' do
        @template.create_file 'sidekiq.yml' do <<~EOF
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
    end

    def add_sidekiq_web
      @template.insert_into_file 'config/routes.rb', before: "Rails.application.routes.draw do\n" do <<~RUBY
      require 'sidekiq/web'
      RUBY
      end

      @template.insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<~RUBY
        namespace :admin do
          authenticate :user, lambda { |u| u.admin? } do
            mount Sidekiq::Web => '/sidekiq'
          end
        end
      RUBY
      end
    end

    def set_job_queue
      @template.insert_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do <<~RUBY
      \tconfig.active_job.queue_adapter = :sidekiq
      RUBY
      end
    end
  end
end
