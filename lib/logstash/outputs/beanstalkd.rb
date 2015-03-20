# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"


class LogStash::Outputs::Beanstalkd < LogStash::Outputs::Base
  config_name "beanstalkd"

  # The address of the beanstalk server
  config :host, :validate => :string, :required => true

  # The port of your beanstalk server
  config :port, :validate => :number, :default => 11300

  # The name of the beanstalk tube
  config :tube, :validate => :string, :required => true

  # The message priority (see beanstalk docs)
  config :priority, :validate => :number, :default => 65536

  # The message delay (see beanstalk docs)
  config :delay, :validate => :number, :default => 0

  # See beanstalk documentation
  config :ttr, :validate => :number, :default => 300

  public
  def register
    require "beaneater"
    @beanstalk = Beaneater::Pool.new(["#{@host}:#{@port}"])
    @beanstalk_tube = @beanstalk.tubes.find(@tube)
  end 

  public
  def receive(event)
    @beanstalk_tube.put(event.to_json, {pri: @priority, delay: @delay, ttr: @ttr})
  end 
end 
