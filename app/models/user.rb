class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
  devise :validatable, password_length: 4..200

  validates :name, presence: true, length: { in: 2..30 }
  validates :email, length: { in: 2..200 }
end
