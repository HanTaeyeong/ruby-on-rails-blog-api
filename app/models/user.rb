class User < ApplicationRecord
    has_many :posts, dependent: :destroy

    has_secure_token :auth_token

    validates :username, presence: true
    validates :email, presence: true, uniqueness: true
end
