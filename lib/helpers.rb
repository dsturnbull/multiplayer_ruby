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
      def process_cookies(options)
        return unless options[:cookies] || default_options[:cookies]
        options[:headers] ||= {}
        options[:headers]["cookie"] = cookies(options[:cookies] || {}).to_cookie_string
        options.delete(:cookies)
      end
    end
  end
end
