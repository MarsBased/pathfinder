module Configurators
  class Monitoring < Base

    askable 'Choose Monitoring Engine:'
    optionable %w(None Sentry Rollbar Airbrake)

    def recipe
      case ask!
      when 'Sentry'
        @pathfinder.add_recipe(Recipes::Sentry.new(@pathfinder))
      when 'Rollbar'
        @pathfinder.add_recipe(Recipes::Rollbar.new(@pathfinder))
      when 'Airbrake'
        @pathfinder.add_recipe(Recipes::Airbrake.new(@pathfinder))
      end
    end

  end
end
