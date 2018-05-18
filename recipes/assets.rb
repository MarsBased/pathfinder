module Recipes
  class Assets < Base

    def gems
      @template.gem 'bootstrap-sass', '~> 3.3.3'
      @template.gem 'font-awesome-sass', '~> 4.7.0'
      @template.gem 'sass-rails'
      @template.gem 'autoprefixer-rails'
      @template.gem 'compass-rails', '~> 3.0.1'
      @template.gem 'magnific-popup-rails'
      @template.gem 'uglifier', '>= 1.3.0'
      @template.gem 'sdoc', '~> 0.4.0', group: :doc
    end

  end
end
