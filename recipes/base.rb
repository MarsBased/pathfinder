module Recipes
  class Base

    def initialize(pathfinder)
      @pathfinder = pathfinder
      @template = pathfinder.template
    end

    def gems
    end

    def init_file
    end
  end
end
