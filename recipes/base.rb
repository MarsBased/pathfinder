require_relative '../concerns/askable'
require_relative '../concerns/optionable'
require_relative '../concerns/confirmable'
require_relative '../concerns/dependable'
require_relative '../concerns/auto_runnable'

module Recipes
  class Base

    include ::Askable
    include ::Optionable
    include ::Confirmable
    include ::Dependable
    include ::AutoRunnable

    def initialize(pathfinder)
      @pathfinder = pathfinder
      @template = pathfinder.template
    end

    def gems
    end

    def cook
    end

    private

    def relative_file_content(path)
      caller_path = caller_locations.first.path
      puts caller_path
      File.read(File.join(File.dirname(caller_path), path))
    end
  end
end
