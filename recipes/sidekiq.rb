module Recipes
  class Sidekiq < Base

    def init_file
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
        get '/404', to: 'errors#not_found'
        get '/500', to: 'errors#internal_error'
      RUBY
      end
    end
  end
end
