require 'uri'
require 'net/http'

module RedmineTimeEntryEvents
  module Patches
    module TimeEntryPatch

      def time_entry_event_request(event, data)
        address = Setting.plugin_redmine_time_entry_events['address']
        if address === ''
          return
        end
        http_login = Setting.plugin_redmine_time_entry_events['http_login']
        http_pass = Setting.plugin_redmine_time_entry_events['http_pass']
        token = Setting.plugin_redmine_time_entry_events['token']
        tries = Setting.plugin_redmine_time_entry_events['tries'].to_i
        if tries < 1
          return
        end

        uri = URI(address)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new uri.request_uri
        if http_login != ''
          request.basic_auth http_login, http_pass
        end

        request.add_field 'Content-Type', 'application/json'
        request.body = {event: event, time_entry: data, token: token}.to_json

        counter = 0
        while counter < tries
          counter = counter + 1
          begin
            response = http.request request
            if response.code == '200'
              return
            end
          rescue # ignored
          end
        end

        log = File.open("#{File.dirname(__FILE__)}/../../../../../log/redmine_time_entry_events.error.log", 'a+')
        log.puts request.body.to_json
        log.close
      end

      def self.included(base)
        base.set_callback :save, :after do
          time_entry_event_request 'save', self
        end

        base.set_callback :destroy, :after do
          time_entry_event_request 'destroy', self
        end
      end
    end
  end
end
