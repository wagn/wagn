# -*- encoding : utf-8 -*-

class AddRecaptchaKeyCards < Card::CoreMigration
  def up
    shared_args = { :type_id=>Card::PhraseID, :subcards=> {
                      '+*self+*read'=>{:content=>'[[Administrator]]'},
                      '+*self+*update'=>{:content=>'[[Administrator]]'},
                      '+*self+*delete'=>{:content=>'[[Administrator]]'},
                    }
                  }
    Card.create! shared_args.deep_clone.merge( :name=>'*recaptcha public key',  :codename=>:recaptcha_public_key )
    Card.create! shared_args.deep_clone.merge( :name=>'*recaptcha private key', :codename=>:recaptcha_private_key )
    Card.create! shared_args.deep_clone.merge( :name=>'*recaptcha proxy',       :codename=>:recaptcha_proxy )
    Card.create! shared_args.deep_clone.merge( :name=>'*recaptcha settings',    :codename=>:recaptcha_settings, :type_id=>Card::BasicID,
    :subcards=>{'+*self+*structure' => {:content=>"{{*recaptcha public key|titled}}\n{{*recaptcha private key|titled}}\n{{*recaptcha proxy|titled}}"}})
  end
end
