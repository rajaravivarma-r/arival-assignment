# frozen_string_literal: true

# A class to abstract errors and give an uniform interface to create,
# serialize and deserialize error objects
class AppError < Data.define(:field, :error_messages)
  class << self
    def from_hash(hash)
      hash.map do |field, error_messages|
        new(field:, error_messages:)
      end
    end
  end

  def initialize(field:, error_messages:)
    super(field: field.to_s, error_messages: Array(error_messages))
  end

  def to_h
    { field => error_messages }
  end
end
