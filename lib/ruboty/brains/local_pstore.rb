require 'ruboty/brains/base'
require 'ruboty/brains/memory'
require 'pstore'

module Ruboty
  module Brains
    class LocalPStore < Base
      KEY = 'brain'

      attr_reader :thread

      env :PSTORE_SAVE_INTERVAL, 'Interval sec to save data to PStore-db (default: 5)', optional: true

      def initialize
        super
        @thread = Thread.new { sync }
        @thread.abort_on_exception = true
      end

      def data
        @data ||= pull || {}
      end

      private

      def push
        db.transaction do
          db[KEY] = data
        end
      end

      def pull
        db.transaction do
          db[KEY]
        end
      end

      def sync
        loop do
          wait
          push
        end
      end

      def wait
        sleep(interval)
      end

      def db
        @db ||= PStore.new('/tmp/__ruboty_pstore__')
      end

      def interval
        (ENV['PSTORE_SAVE_INTERVAL'] || 5).to_i
      end
    end
  end
end
