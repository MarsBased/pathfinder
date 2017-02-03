module Recipes
  class Pundit < Base

    def gems
      @template.gem 'pundit'
    end

    def init_file
      @template.generate 'pundit:install'
      @template.insert_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-RUBY
        include Pundit
        RUBY
      end
    end
  end
end
