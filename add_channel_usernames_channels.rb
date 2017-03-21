#!/usr/bin/env ruby
require './SlackAPIAdaptor'

slack = SlackAPIAdaptor.new

user_names = ARGV[0].gsub(/,/, " ").gsub(/[^a-z.\s]/, '').split(" ").select {|n| n.length > 0 }
  channels = ARGV[1].gsub(/,/, " ").gsub(/[^a-z0-9_\s-]/, '').split(" ").select {|n| n.length > 0 }


puts user_names
puts channels

user_names.each do |user_name|
  channels.each do |channel_name|
    channel = slack.channel(channel_name)
    user = slack.member(user_name)
    response = slack.api_call("channels.invite", { channel: channel["id"], user: user["id"] } )
    puts response
    puts response.body
  end
end
