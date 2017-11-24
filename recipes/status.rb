module Recipes
  class Status < Base

    def init_file
      set_route_path
      add_controller
    end

    private

    def set_route_path
      @template.insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<~RUBY
        \s\sresource :status, only: :show
      RUBY
      end
    end

    def add_controller
      @template.copy_file(File.join(File.dirname(__FILE__), 'controllers', 'statuses_controller.rb'), 'app/controllers/statuses_controller.rb')
    end
  end

end
