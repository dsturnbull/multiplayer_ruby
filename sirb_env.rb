require 'rubygems'
require 'drb'
require 'json'
require 'socket'
require 'thread'
require 'sandbox'
require 'stringio'
require 'htmlentities'

class SIRB
  def initialize
    @context = binding
    @history = {}
    @mutex = Mutex.new
  end

  def history(user, page, per_page, matcher)
    start = (page - 1) * per_page
    finish = start + per_page - 1
    p user
    p user[:id]
    @history[user[:id]].reverse[start..finish].to_enum(:each_with_index).map do |cmd, id|
      { :id => id, :cmd => cmd }
    end
  rescue
    []
  end

  def execute(user, cmd)
    stdout = []
    @history[user[:id]] ||= []
    @history[user[:id]].push(cmd)
    @mutex.synchronize do
      begin
        _stdout = $stdout
        $stdout = StringIO.new("")
        stdout << user[:prompt] + cmd
        output = @context.eval(cmd).inspect
        $stdout.rewind
        stdout += $stdout.read.split("\n")
        stdout << "=>#{output}"
      rescue Exception => e
        stdout << e.inspect[2 .. e.inspect.length - 2]
      ensure
        $stdout = _stdout
      end
    end
    stdout
  end

  def ping
    :ok
  end
end

class SIRBServer
  @@uri = "druby://localhost:9000"

  def self.encoded_result(result)
    { :result => encoded(result) }.to_json
  end

  def self.encoded(result)
    # sigh
    encoder = HTMLEntities.new

    if result.is_a?(Array)
      result.map { |v| encoded(v) }
    elsif result.is_a?(Hash)
      result.inject({}) { |c, pair| k, v = pair; c[encoded(k)] = encoded(v); c }
    elsif result.is_a?(String)
      encoder.encode(result, :named)
    elsif result.is_a?(Symbol)
      encoded(result.to_s)
    else
      result
    end
  end

  def self.history(*args)
    encoded(self.initialize_interface.history(*args)).to_json
  end

  def self.execute(*args)
    encoded_result(self.initialize_interface.execute(*args))
  end

  def self.initialize_interface
    DRb.start_service
    sirb = DRbObject.new(nil, @@uri)
    sirb.ping
    sirb
  rescue
    fork { SIRBServer.new }
    sleep 1
    retry
  end

  def initialize
    sirb = SIRB.new
    DRb.start_service(@@uri, sirb)
    DRb.thread.join
  end
end

if $0 == __FILE__
  SIRBServer.new
end
