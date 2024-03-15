class User < Tempest::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # Devise setup
  devise :invitable, :trackable, :database_authenticatable, :registerable,
         :recoverable, :rememberable
end
