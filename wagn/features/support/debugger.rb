# `LAUNCHY=1 cucumber` to open page on failure
After do |scenario|
  save_and_open_page if scenario.failed? && ENV["LAUNCHY"]
end

# `FAST=1 cucumber` to stop on first failure
After do |scenario|
  Cucumber.wants_to_quit = ENV["FAST"] && scenario.failed?
end

# `DEBUG=1 cucumber` to drop into debugger on failure
After do |scenario|
  next unless ENV["DEBUG"] && scenario.failed?
  puts "Debugging scenario: #{scenario.name}"
  if respond_to? :debugger
    debugger
  elsif binding.respond_to? :pry
    binding.pry #
  else
    puts "Can't find debugger or pry to debug"
  end
end

# `STEP=1 cucumber` to pause after each step
AfterStep do |_result, _step|
  next unless ENV["STEP"]
  unless defined?(@counter)
    #puts "Stepping through #{scenario.name}"
    @counter = 0
  end
  @counter += 1
  #print "At step ##{@counter} of #{scenario.steps.count}. Press Return to"\
  #      " execute..."
  print "Press Return to execute next step...\n"\
          "(d=debug, c=continue, s=step, a=abort)"
  case STDIN.getch
  when "d" then
    binding.pry #
  when "c" then
    ENV.delete "STEP"
  when "a" then
    Cucumber.wants_to_quit = true
  end
end
