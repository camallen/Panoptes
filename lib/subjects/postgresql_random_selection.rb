module Subjects
  class PostgresqlRandomSelection
    using Refinements::RangeClamping

    attr_reader :available, :limit

    def initialize(available, limit)
      @available = available
      @limit = limit
    end

    def select
      # TODO move this from pluck which will bring back a lot of records
      # to just a straight limit selection on the focus window?
      # it'll not be as random but it won't stress the database as much
      # proper random selection can be done using cellect / designator
      ids = available_scope.pluck(:id).sample(limit)
      if reassign_random?
        RandomOrderShuffleWorker.perform_async(ids)
      end
      ids
    end

    private

    def available_scope
      if limit < available_count
        focus_window_random_sample
      else
        available
      end
    end

    def available_count
      @available_count ||= available.except(:select).count
    end

    def focus_window_random_sample
      # maybe instead just do
      # available
      #  .order(random: [:asc, :desc].sample)
      #  .limit(limit*(1,2,5,10).sample) # or just a min of a 100
      available.order(random: [:asc, :desc].sample).limit(focus_set_window_size)
    end

    def focus_set_window_size
      @focus_set_window_size ||=
        [
          limit_window,
          Panoptes::SubjectSelection.focus_set_window_size
        ].min
    end

    def limit_window
      half_available_count = (available_count * 0.5).ceil
      if half_available_count < limit
        limit
      else
        half_available_count
      end
    end

    def reassign_random?
      rand <= Panoptes::SubjectSelection.index_rebuild_rate
    end
  end
end
