class Symbol
  def to_proc
    Proc.new { |obj, *args| obj.send(self, *args) }
  end
end

class String
  def blank?
    self == ""
  end
end

class NilClass
  def blank?
    true
  end
end

if defined? Sinatra
  module Sinatra
    class Base
      private
        alias_method :shitty_nested_params, :nested_params
        def nested_params(*args)
          begin
            raw = request.env["rack.input"].read
            JSON.parse(raw)
          rescue
            shitty_nested_params(*args)
          end
        end
    end
  end
end

if defined? HTTParty
  module HTTParty::Hacks
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # hax, since httparty doesn't do cookies properly yet.
      def post(action, options={})
        add_cookie!(options)
        super(action, options)
      end
      
      def get(action, options={})
        add_cookie!(options)
        super(action, options)
      end

      def add_cookie!(options)
        options[:query] ||= {}
        options[:query][:cookie] = cookies['rack.session']
      end
    end
  end
end
