# frozen_string_literal: true

require 'sidekiq-scheduler'

##
#
class CommTemplateWorker
  include Sidekiq::Worker

  def perform(template_id = nil)
    templates = CommTemplate.active_template
    templates = if template_id.present?
                  templates.where(id: template_id)
                else
                  templates.where.not("COALESCE(trigger, '') = ''")
                end

    templates.each do |template|
      people = eval(template.trigger)

      people.each do |person|
        comm = person.comms.create(comm_template: template)

        comm&.dispatch
      end
    end
  end

  ##
  # Returns states that the time (hour) matches the hour passed
  # @param hour[Integer]
  # @return [Array]
  def states_on_hour(hour)
    matching_states = []

    city_zones = { 'sa' => 'Australia/Adelaide', 'wa' => 'Australia/Perth', 'nt' => 'Australia/Darwin',
                   'vic' => 'Australia/Melbourne', 'tas' => 'Australia/Hobart',
                   'qld' => 'Australia/Sydney', 'act' => 'Australia/Melbourne' }

    city_zones.each do |k, v|
      matching_states.push(k) if ActiveSupport::TimeZone.new(v).now.hour == hour
    end
    matching_states
  end
end
