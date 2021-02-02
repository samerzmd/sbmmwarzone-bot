# frozen_string_literal: true

require 'discordrb'
require 'cgi'
require 'open-uri'
require 'byebug'

token = Rails.application.credentials.discord[:token]

# Here we instantiate a `CommandBot` instead of a regular `Bot`, which has the functionality to add commands using the
# `command` method. We have to set a `prefix` here, which will be the character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: token, prefix: 'cod '

bot.command(:profile, user_name: nil) do |event, user_name|
  user_name_encoded = CGI.escape(user_name)
  response = Faraday.get("https://app.sbmmwarzone.com/player?username=#{user_name_encoded}&platform=battle")
  data = JSON.parse(response.body)&.dig('data')
  summary = data.dig('lifetime', 'all', 'properties')
  event.channel.send_embed do |embed|
    embed.title = 'COD Summary'
    embed.colour = 0xcd21c8
    embed.description = "**Player Name**: #{user_name}"
    embed.author = Discordrb::Webhooks::EmbedAuthor
                   .new(name: event.author.username.to_s,
                        url: 'https://discordapp.com',
                        icon_url: event.author.avatar_url)

    embed.add_field(name: ':chart_with_upwards_trend: **level**',
                    value: data&.dig('level'), inline: true)
    embed.add_field(name: ':goal: **score**',
                    value: summary&.dig('score'), inline: true)
    embed.add_field(name: "\b",
                    value: "\b", inline: false)
    embed.add_field(name: ':tada: **wins**',
                    value: "|  #{summary&.dig('wins')}  |", inline: true)
    embed.add_field(name: ':cry: **losses**',
                    value: "|  #{summary&.dig('losses')}  |", inline: true)
    embed.add_field(name: ':triumph: **ties**',
                    value: "|  #{summary&.dig('ties')}  |", inline: true)
  end
end

bot.run
