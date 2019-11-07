module Recipes
  class Assets < Base

    is_auto_runnable

    def gems
      @template.gem 'autoprefixer-rails'
      @template.gem 'magnific-popup-rails'
      @template.gem 'uglifier', '>= 1.3.0'
      @template.gem 'sdoc', '~> 0.4.0', group: :doc
    end

  end
end
