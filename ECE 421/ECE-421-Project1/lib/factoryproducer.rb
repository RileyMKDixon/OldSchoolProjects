require_relative 'csrfactory.rb'
require_relative 'dokfactory.rb'

class Factoryproducer
    def self.get_factory(type)
        # pre conditions
        # type is a string representing a valid type ('csr' only for now) that has a factory
        if type == 'csr'
            Csrfactory.new
        elsif type == 'dok'
            Dokfactory.new
        end

        # post condition
        # factory for specified type
    end
end