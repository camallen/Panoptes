# frozen_string_literal: true

module CsvDumps
  class CachingDumpProcessor < DumpProcessor
    attr_accessor :yield_block

    def initialize(formatter, scope, medium, csv_dump=nil, &block)
      super(formatter, scope, medium, csv_dump)
      @yield_block = block
    end

    def perform_dump
      csv_dump << formatter.headers unless formatter.headers.empty?

      scope.each do |model|
        # update the model being formatted to the current instance
        formatter.model = model
        # use a caching formatter delegator to wrap the
        # model's cached_export (if it exists) and main formatter
        # to optimize exports by using pre-computed cache resources
        caching_formatter = Formatter::Caching.new(model.cached_export, formatter)

        # create the row of csv data using the caching formatter delegator
        row = formatter.headers.map { |header| caching_formatter.send(header) }
        csv_dump << row

        # yield the caching_formatter to the calling context
        # as it knows how best to persist the cacheable resource
        #
        # Note: this must call with the caching formatter
        # if not we will reprocess
        yield_block.call(caching_formatter)
      end
    end
  end
end
