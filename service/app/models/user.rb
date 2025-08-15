class User < ApplicationRecord
  validates :firebase_local_id, presence: true, uniqueness: true
end
