class BaseService
  class Result < Data.define(:success, :value, :errors)
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
