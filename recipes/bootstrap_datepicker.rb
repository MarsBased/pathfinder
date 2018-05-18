module Recipes
  class BootstrapDatepicker < Base

    is_auto_runnable

    askable 'Do you want to use Bootstrap datepicker?'
    confirmable true

    def gems
      @template.gem 'bootstrap-datepicker-rails', '~> 1.6.0'
    end

  end
end
