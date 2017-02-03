class Utils

  def initialize(template)
    @template = template
  end

  def ask_with_default(question, default:)
    answer = @template.ask("#{question} (Default #{default})")
    answer.empty? ? default : answer
  end

end
