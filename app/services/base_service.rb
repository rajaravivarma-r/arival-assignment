# frozen_string_literal: true

# Provides a platform to build other service classes
class BaseService
  Result = Data.define(:success, :value, :errors) do
    class << self
      def success(value:)
        new(success: true, value:)
      end

      def failure(errors:)
        new(success: false, errors:)
      end
    end

    def initialize(success:, value: nil, errors: [])
      super(success:, value:, errors:)
    end

    def success?
      success
    end
  end

  private

  def errors_from_hash(hash)
    AppError.from_hash(hash)
  end

  def construct_error(field:, error_messages:)
    AppError.new(field:, error_messages:)
  end
end
