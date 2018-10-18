module Configurators
  class Sentry < Base

    askable 'Do you want send cookies and POST data to Sentry?'
    dependable 'Recipes::Sentry'
    is_confirmable

    def cook
      add_initializer if ask!
    end

    private

    def add_initializer
      @template.initializer 'sentry.rb', <<~CODE
      Raven.configure do |config|
      \s\sconfig.processors -= [Raven::Processor::PostData] # Do this to send POST data
      \s\sconfig.processors -= [Raven::Processor::Cookies] # Do this to send cookies by default
      end
      CODE
    end

  end
end
