module Recipes
  class ActiveAdmin < Base

    def gems
      if @template.ask 'Will you need ActiveAdmin to have an admin area?'
        @install = true
        @template.gem 'activeadmin'
        @template.gem 'turbolinks'
      end
    end

    def init_file
      return unless @install
      msg = 'What will be the main user class for Devise and ActiveAdmin?'
      user_classname = @template.ask msg, default: 'User'
      @template.run "rails g active_admin:install #{user_classname}"
    end
  end
end
