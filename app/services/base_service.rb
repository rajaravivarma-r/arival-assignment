class BaseService
  Result = Data.define(:success, :value, :errors) do
    def initialize(success:, value: nil, errors: [])
      super(success:, value:, errors:)
    end

    def success?
      success
    end
  end
end
