require 'slack-ruby-client'
require 'pp'
require 'logger'

# Set up some config options
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

# Set up our output channel
output_channel = ENV["SLACK_NOTIFICATIONS_CHANNEL"]
fail 'Missing ENV["SLACK_NOTIFICATIONS_CHANNEL"]' unless output_channel

# Create the client
client = Slack::RealTime::Client.new

# Output some info when we join
client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  puts "Configuration: Channel = #{output_channel}"
end

# When a new channel is created
client.on :channel_created do |data|
  client.web_client.chat_postMessage(
    channel: "\##{output_channel}",
    as_user: true,
    attachments: [ { 
      color: "#7CD197",
      title: "New Channel Created",
      fallback: "New Channel Created by <@#{data['channel']['creator']}>: <\##{data['channel']['id']}>",
      text: "Created by <@#{data['channel']['creator']}> Name: <\##{data['channel']['id']}>"
    }
    ],
  )
end

# When a channel is archived
client.on :channel_archive do |data|
  client.web_client.chat_postMessage(
  channel: "\##{output_channel}",
  as_user: true,
  attachments: [ {
    color: "#FF0000",
    title: "Channel Archived",
    fallback: "Channel was archived by <@#{data['user']}>: <\##{data['channel']}>",
    text: "Archived by <@#{data['user']}>: <\##{data['channel']}>",
  }]
  )
end

# When a channel is renamed
client.on :channel_rename do |data|
  client.web_client.chat_postMessage(
  channel: "\##{output_channel}",
  as_user: true,
  attachments: [ {
    color: "#FF0000",
    title: "Channel Renamed",
    fallback: "Channel <\##{data['channel']['id']}> was renamed",
    text: "Channel <\##{data['channel']['id']}> was renamed",
  }]
  )
end

client.start!
