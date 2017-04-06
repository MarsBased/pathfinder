module Recipes
  class Redis < Base

    def init_file
      @template.initializer 'redis.rb', <<~CODE
        Redis.current = Redis.new(Rails.application.config_for(:redis))
      CODE

      @template.inside 'config' do
        @template.create_file 'redis.yml' do <<~EOF
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
  end
end
