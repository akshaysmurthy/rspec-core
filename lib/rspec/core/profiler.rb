module RSpec
  module Core
    # @private
    class NoProfiler
      def self.notifications
        []
      end

      def self.example_groups
        {}
      end
    end

    # @private
    class Profiler
      NOTIFICATIONS = [:example_group_started, :example_group_finished, :example_started]

      def initialize
        @example_groups = Hash.new { |h, k| h[k] = Hash.new(0) }
      end

      attr_reader :example_groups

      def notifications
        NOTIFICATIONS
      end

      def example_group_started(notification)
        @example_groups[notification.group.id][:start] = Time.now
        @example_groups[notification.group.id][:description] = notification.group.top_level_description
      end

      def example_group_finished(notification)
        @example_groups[notification.group.id][:total_time] =  Time.now - @example_groups[notification.group.id][:start]
      end

      def example_started(notification)
        group = notification.example.example_group.parent_groups.last.id
        @example_groups[group][:count] += 1
      end

    end
  end
end
