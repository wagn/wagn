class UpdateInviteSender < ActiveRecord::Migration
  def up
    dbtype = ActiveRecord::Base.configurations[Rails.env]['adapter']

    if dbtype.to_s =~ /mysql/
      execute %{update users u1, users u2 set u1.invite_sender_id = u2.card_id
                 where u1.invite_sender_id = u2.id }

    else
      execute %{update users as u1 set u1.invite_sender_id = u2.card_id from users u2
                 where u1.invite_sender_id = u2.id }

    end
  end

  def down
    if dbtype.to_s =~ /mysql/
      execute %{update users u1, users u2 set u1.invite_sender_id = u2.id
                 where u1.invite_sender_id = u2.card_id }

    else
      execute %{update users as u1 set u1.invite_sender_id = u2.id from users u2
                 where u1.invite_sender_id = u2.card_id }

    end
    
  end
end
