module JsonSerializers
  class UserSerializer
    attr_reader :user

    class << self
      def serialize(user)
        new(user).as_json
      end
    end

    def initialize(user)
      @user = user
    end

    def as_json
      {
        email: user.email
      }
    end
  end
end
