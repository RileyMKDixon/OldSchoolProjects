require 'contracts'

module Custom
    class ComparableArray
        include Contracts::Core
        C = Contracts

        Contract C::Any => C::Bool
        def self.valid?(val)
            if !val.is_a?(Array)
                return false
            else
                type = val[0].class
                val.each do |item|
                    if item.class != type
                        return false
                    end
                end
                return true
            end
        end

        def self.to_s
            "A single-typed array of Comparables"
        end
    end
end