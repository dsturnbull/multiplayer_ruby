require 'rubygems'
require 'active_support/core_ext/class/attribute_accessors.rb'
require 'active_support/core_ext/array'
require 'json'
require 'httparty'

SIRB_HOST = ARGV[0]
SIRB_PORT = ARGV[1]
SIRB_SESSION_FILE = "#{ENV['HOME']}/.sirb_session"

class SIRBClient
  include HTTParty
  base_uri "http://#{SIRB_HOST}:#{SIRB_PORT}/"

  def self.get_session
    if File.exists?(SIRB_SESSION_FILE)
      File.read(SIRB_SESSION_FILE)
    else
      File.open(SIRB_SESSION_FILE, 'w') do |session_file|
        session = self.get('/').headers['set-cookie'].pop
        session_file << session.match(/=(.*);/)[1]
      end
    end
  end

  cookies 'rack.session' => SIRBClient.get_session

  def self.execute(args)
    Readline::HISTORY.push(args[:cmd])
    self.post('/sirb', :query => args)['result'].join("\n")
  end

  def self.prompt
    self.get('/sirb_prompt')['result']
  end

  def self.history(page, per_page)
    self.get('/sirb_history', :query => { :page => page, :per_page => per_page }).reverse
  end

  def self.set_history
    self.history(1, 1000).each do |result|
      cmd = result['cmd']
      unless cmd.blank?
        Readline::HISTORY.push(cmd)
      end
    end
  end

  def self.method_missing(method, *args, &block)
    @@client ||= SIRBClient.new
    @@client.send(method, *args, &block)
  end
end
