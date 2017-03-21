require 'uri'
require 'net/https'
require 'date'
require 'json'

# 設定（tokenは環境変数で設定が必要）
SLACK_TOKEN = ENV.fetch('SLACK_TOKEN', nil)
raise "SLACK_TOKEN is nil" if SLACK_TOKEN.nil?

SLACK_URI = URI.parse 'https://slack.com/api/'
DEBUG = true

class SlackAPIAdaptor

  def connection
    @connection ||= Net::HTTP.new(SLACK_URI.host, SLACK_URI.port).tap do |https|
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
  end
  
  def api_call(method, params, debug=DEBUG)
    puts method if debug
    puts params.inspect if debug

    params[:token] = SLACK_TOKEN
    request = Net::HTTP::Post.new ("#{SLACK_URI.path}/#{method}")
    request.set_form_data(params)
    response = connection.request(request)

    puts response.inspect if debug
    response
  end

  def channel(name, params={})
    channels({name: [name]}, params)[0]
  end

  def member(name, params={})
    members({name: [name]}, params)[0]
  end

  def group(name, params={})
    groups({handle: [name]}, params)[0]
  end

  def filter(data, filters)
    unless data.respond_to?(:select)
      puts data.class.to_s
      puts data.inspect if data.respond_to?(:inspect)
      return []
    end
    data.select do |datum|
      filters.map { |key, list| list.include?(datum[key.to_s]) }.all? 
    end
  end

  def channels(filters, params={})
    @channels ||=  api_call("channels.list", params)
    filter(JSON.parse(@channels.body)["channels"], filters)
  end

  def members(filters, params={})
    @members ||= api_call("users.list", params)
    filter(JSON.parse(@members.body)["members"], filters)
  end

  def groups(filters, params={})
    @usergroups ||= api_call("usergroups.list", params)
    filter(JSON.parse(@usergroups.body)["usergroups"], filters)
  end

end
