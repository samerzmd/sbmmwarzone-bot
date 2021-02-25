# frozen_string_literal: true

require 'discordrb'
require 'cgi'
require 'open-uri'
require 'byebug'

class BotRunner
  def initialize
    token = Rails.application.credentials.discord[:token]
    @bot = Discordrb::Commands::CommandBot.new token: token, prefix: 'cod '
    Commands::ProfileCommand.new(@bot)
  end

  def run
    Thread.new do
      Rails.application.executor.wrap do
        @bot.run
      end
    end
  end
end
