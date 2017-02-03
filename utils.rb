def ask_with_default(question, default:)
  answer = ask("#{question} (Default #{default})")
  answer.empty? ? default : answer
end
