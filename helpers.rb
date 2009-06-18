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


