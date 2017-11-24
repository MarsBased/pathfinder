module Recipes
  class ActiveAdmin < Base

    def gems
      if @template.yes? 'Will you need ActiveAdmin to have an admin area?'
        @install = true
        @template.gem 'activeadmin'
      end
    end

    def init_file
      return unless @install
      msg = 'What will be the main user class for Devise and ActiveAdmin?'
      user_classname = @template.ask msg, default: 'AdminUser'
      @template.run "rails g active_admin:install #{user_classname}"
    end
  end
end
