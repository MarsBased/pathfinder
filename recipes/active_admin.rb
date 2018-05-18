module Recipes
  class ActiveAdmin < Base

    is_auto_runnable

    askable 'Will you need ActiveAdmin to have an admin area?'
    confirmable true

    def gems
      @template.gem 'activeadmin'
    end
  end
end
