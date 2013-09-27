# teleport.rake
#
# Run the Teleport gem to provision the server. Config files are found in
# config/teleport.

task :teleport, :hostname do |t, args|
  $VERBOSE = true

  hostname = 'showgap'

  if args.hostname
    hostname = args.hostname
  else
    next unless yes_question "Provisioning default hostname, showgap"
  end

  Dir.chdir File.join('config', 'teleport')
  system("bundle exec teleport #{hostname}")
end

# Public: Ask a question with the default answer of yes on STDIN.
#
# message - The text of the question to ask.
#
# Returns true if the answer is yes, false if not.
def yes_question(message)
  print "#{message}. Is that okay? [Yn] "
  if STDIN::gets.strip.downcase == 'n'
    puts "Alright, I'll stop."
    false
  else
    true
  end
end
