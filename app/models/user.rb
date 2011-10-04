class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :omniauthable
  
  ROLES = %w[admin] # Add more roles as you go

  field :name, :type => String
  field :email, :type => String
  field :role, :type => String
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    logger.info access_token
    if user = User.first(conditions: { email: data["email"] } )
      user
    else # Create a user with a stub password. 
      User.create(:email => data["email"], :name => data["name"], :omniauth_provider => 'facebook', :password => Devise.friendly_token[0,20]) 
    end
  end
  
  def self.find_for_open_id(access_token, signed_in_resource=nil, provider=nil)
    data = access_token['user_info']
    if user = User.first(conditions: { email: data["email"] } )
      user
    else # Create a user with a stub password. 
      User.create(:email => data["email"], :name => data["name"], :omniauth_provider => provider, :password => Devise.friendly_token[0,20]) 
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end
end