module Services
  class ExpandRecurringBlockOut
    include Procto.call
    include Concord.new(:block_out)
    include Adamantium::Flat

    def call
      return unless block_out.persisted? || save_block_out
      block_out.occurrences.delete_all
      bulk_insert_occurrences if occurrences.any?
    end

    private

    def save_block_out
      block_out.update(last_occurrence: rrule.last_occurrence)
    end

    def rrule
      OmdRrule.new(block_out.rrule,
                   dtstart: block_out.start_at,
                   exdate: block_out.exdate,
                   tzid: block_out.user.time_zone)
    end

    def occurrences
      rrule.current_occurrence_times.map do |rt|
        shared_attributes.merge(
          parent_id: block_out.id,
          start_at: rt,
          end_at: rt.advance(seconds: block_out.duration_in_seconds)
        )
      end
    end
    memoize(:occurrences)

    def shared_attributes
      attrs = block_out.attributes.symbolize_keys
      attrs.slice(:user_id,
                  :created_at,
                  :updated_at)
    end

    # TODO: Turn me into my own service class
    def bulk_insert_occurrences
      keys = occurrences.first.keys.join(', ')
      values = occurrences.map { |h| "(#{h.values.map { |v| "'#{v.respond_to?(:utc) ? v.utc : v}'" }.join(',')})" }.join(',')
      ActiveRecord::Base.connection.execute("INSERT INTO block_outs (#{keys}) VALUES #{values}")
    end
  end
end
