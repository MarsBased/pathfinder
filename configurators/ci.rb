module Configurators
  class Ci < Base

    askable 'Will you use a CI system'
    optionable %w(CircleCI None)

    def recipe
      case ask!
      when 'CircleCI'
        @pathfinder.add_recipe(Recipes::CircleCi.new(@pathfinder))
      end
    end
  end
end
