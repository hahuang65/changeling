module Changeling
  module Blameling
    def self.included(base)
      base.before_filter :set_changeling_blame_user
    end

    protected
      def changeling_blame_user
        current_user rescue nil
      end

    private
      def set_changeling_blame_user
        Changeling.blame_user = changeling_blame_user
      end
  end
end
