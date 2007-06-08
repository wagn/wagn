# There used to be lots of methods here. Unfortunately I ran into some weird cases
# with renderer(which needs access to helper methods)
# where an ApplicationHelper module was defined but didn't include 
# the methods defined in the application_helper.rb, so I moved everything out
# to wagn_helper.rb and include that explicitly in most of the controllers.  
# someday might want to come back and tease that out.. -- LWH


