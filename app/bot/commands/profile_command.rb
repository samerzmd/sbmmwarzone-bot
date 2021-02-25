# frozen_string_literal: true

module Commands
  # Here we instantiate a `CommandBot` instead of a regular `Bot`, which has
  # the functionality to add commands using the
  # `command` method. We have to set a `prefix` here, which will be the character
  # that triggers command execution.
  class ProfileCommand
    def initialize(bot)
      bot.command(:profile, user_name: nil) do |event, user_name|
        user_name_encoded = CGI.escape(user_name)
        response = Faraday.get("https://app.sbmmwarzone.com/player?username=#{user_name_encoded}&platform=battle")
        data = JSON.parse(response.body)&.dig('data')
        summary = data.dig('lifetime', 'all', 'properties')
        event.channel.send_embed do |embed|
          header(embed, event, user_name)
          fields(embed, data, summary)
        end
      end
    end

    def header(embed, event, user_name)
      embed.title = 'COD Summary'
      embed.colour = 0xcd21c8
      embed.description = "**Player Name**: #{user_name}"
      embed.author = Discordrb::Webhooks::EmbedAuthor
                     .new(name: event.author.username.to_s,
                          url: 'https://discordapp.com',
                          icon_url: event.author.avatar_url)
    end

    def fields(embed, _data, _summary)
      [
        level,
        score,
        empty_lines,
        wins,
        losses,
        ties
      ].each do |field|
        embed.add_field(field)
      end
    end

    def level
      { name: ':chart_with_upwards_trend: **level**',
        value: data&.dig('level'), inline: true }
    end

    def score
      { name: ':goal: **score**',
        value: summary&.dig('score'), inline: true }
    end

    def wins
      { name: ':tada: **wins**',
        value: "|  #{summary&.dig('wins')}  |", inline: true }
    end

    def losses
      { name: ':cry: **losses**',
        value: "|  #{summary&.dig('losses')}  |", inline: true }
    end

    def ties
      { name: ':triumph: **ties**',
        value: "|  #{summary&.dig('ties')}  |", inline: true }
    end

    def empty_lines
      { name: "\b",
        value: "\b", inline: false }
    end
  end
end
