# frozen_string_literal: true

# Repository for user objects

class UserRepository
  def initialize(storage:)
    @storage = storage
  end

  def create(user)
    storage.save(user.attributes)
  end
end
