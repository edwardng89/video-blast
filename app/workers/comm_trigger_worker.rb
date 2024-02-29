require 'sidekiq-scheduler'

##
# Handles Comm Triggers
class CommTriggerWorker
  include Sidekiq::Worker

  ##
  # Runs through the comm triggers and sends valid comms
  def perform(trigger_id = nil, preview = false)
    events = trigger_id.present? ? CommTrigger.where(id: trigger_id) : CommTrigger.active(true).active_template
    recipients = []

    events.each do |trigger|
      trigger_run = true

      unless preview || trigger.last_checked.blank?
        last_checked = trigger.last_checked
        current_time = DateTime.current.in_time_zone

        case trigger.execute_cycle.to_s
        when 'five_minutes'
          trigger_run = current_time >= (last_checked + 5.minutes)
        when 'thirty_minutes'
          trigger_run = current_time >= (last_checked + 30.minutes)
        when 'hourly'
          trigger_run = current_time >= (last_checked + 1.hour)
        when 'daily'
          trigger_run = current_time >= (last_checked + 1.day)
        when 'day_based'
          case trigger.send_day.to_s
          when 'monday'
            trigger_run = current_time.wday == 1
          when 'tuesday'
            trigger_run = current_time.wday == 2
          when 'wednesday'
            trigger_run = current_time.wday == 3
          when 'thursday'
            trigger_run = current_time.wday == 4
          when 'friday'
            trigger_run = current_time.wday == 5
          when 'saturday'
            trigger_run = current_time.wday == 6
          when 'sunday'
            trigger_run = current_time.wday.zero?
          when 'first_of_month'
            trigger_run = current_time.day == 1
          when 'fifteenth_of_month'
            trigger_run = current_time.day == 15
          end
        end
      end

      next unless trigger_run

      source = trigger.anchor_model.constantize
      template = trigger.comm_template

      return unless source.present?

      # Get the base collection of valid records from the rule then apply the scopes each trigger
      base_records = source.all

      scopes  = trigger.scopes.present? ? JSON.parse(trigger.scopes).reject(&:blank?) : []
      records = base_records

      if trigger.effective_from.present?
        records = records.where("#{trigger.anchor_date_field} >= ?",
                                trigger.effective_from.in_time_zone.beginning_of_day)
      end

      scopes.each do |scope|
        records = records.send(scope.to_sym)
      end

      # Loop through the records defined in the event method file
      records.each do |record|
        existing_comm = false
        date_source     = trigger.anchor_date_field
        timing          = trigger.timing.to_s
        interval        = trigger.interval
        interval_qty    = trigger.qty

        # FIXME: implement direct_to concept
        send_to = record.user

        # FIXME: add this handling when concept of unsubscribed added to the devise model
        # next if template.allow_unsubscribe && send_to.

        comm = template.comms.new(user: send_to, comm_trigger: trigger, trigger_record_id: record.id)

        # If trigger set to check for existing look to see if we already have a letter matching that
        # which we are trying to create
        if trigger.send_once
          existing_comm = Comm.where(user: send_to, comm_trigger: trigger, trigger_record_id: record.id,
                                     comm_template_id: template.id).present?
        end

        # Don't proceed further if we already have an previously sent comm
        next if existing_comm

        date = record.send(date_source.to_sym) if date_source.present?

        # Use the sending rules to check if record meets the requirements of the trigger to be
        # sent
        send_comm = case timing
                    when 'immediate_when_set'
                      true
                    when 'n_after_anchor_date'
                      begin
                        ((date + interval_qty.send(interval.to_sym)) <= DateTime.current.in_time_zone)
                      rescue StandardError
                        false
                      end
                    when 'n_before_anchor_date'
                      begin
                        ((date - interval_qty.send(interval.to_sym)) <= DateTime.current.in_time_zone)
                      rescue StandardError
                        false
                      end
                    else
                      false
                    end

        recipients.push(send_to) if preview && send_comm

        next unless send_comm && !preview

        # Don't call attachment method until now as some letters will be generating the attachment
        # in the method call directly above
        attachment = template.comm_attachments.present? ? template.comm_attachments.map(&:file) : []
        comm.save
        comm.dispatch(attachment, trigger.id)

        next unless trigger.comm_templates.present?

        trigger.comm_templates.each do |additional_template|
          additional_attachments = additional_template.comm_attachments.present? ? additional_template.comm_attachments.map(&:file) : []
          additional_comm = additional_template.comms.create(user: send_to, comm_trigger: trigger,
                                                             trigger_record_id: record.id)
          additional_comm.dispatch(additional_attachments, trigger.id)
        end
      end

      trigger.update(last_checked: DateTime.current.in_time_zone)
    end

    recipients if preview
  end
end
