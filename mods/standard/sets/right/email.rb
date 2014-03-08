#event :


#validates :email, :presence=>true, :if=>:email_required?,
#  :uniqueness => { :scope   => :login                                      },
#  :format     => { :with    => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i },
#  :length     => { :maximum => 100                                         }
#

#before validation
def downcase_email!
  if e = self.email and e != e.downcase
    self.email=e.downcase
  end
end



def email_required?
  !built_in?
end
