require 'set'

module LibreFrame
  module Core
    # A hash subclass which records the keys accessed. This may then be used
    # to verify which keys were accessed or not accessed.
    class AuditHash < Hash
      def initialize(*args, &block)
        super(*args, &block)

        @accessed_keys = Set.new
      end

      def [](key)
        res = super(key)

        @accessed_keys << key

        res
      end

      # Returns an array of all keys accessed during this hash's lifetime. May
      # contain keys which have since been cleared, or which were nil.
      def accessed_keys
        @accessed_keys.to_a
      end

      # Returns an array of the keys which this hash has, but were never
      # accessed.
      def non_accessed_keys
        keys - @accessed_keys.to_a
      end

      def self.from_hash(hash)
        audit_hash = AuditHash.new(hash)
        hash.each do |k, v|
          audit_hash[k] = v.is_a?(Hash) \
            ? AuditHash.from_hash(v)
            : v
        end
        audit_hash
      end
    end
  end
end