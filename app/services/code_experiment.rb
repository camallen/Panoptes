class CodeExperiment
  include ActiveModel::Model

  attr_accessor :id, :name, :enabled_rate, :always_enabled_for_admins, :cached_at
  cattr_writer :always_enabled, :raise_on_mismatches

  def self.run(name, opts={})
    config = CodeExperimentConfig.cache_or_create(name)
    experiment = new(config)
    experiment.context({})

    yield experiment

    test = opts[:run] if opts
    experiment.run(test)
  end

  def self.reporter
    ## REMOVED THE LIBRATO REPORTER
    @reporter ||= CodeExperiments::LogReporter.new
  end

  def self.reporter=(reporter)
    @reporter = reporter
  end

  def self.always_enabled?
    @always_enabled
  end

  def enabled?
    return true if self.class.always_enabled?
    return true if always_enabled_for_admins && admin_user?

    enabled_rate > 0 && rand < enabled_rate
  end

  def publish(result)
    self.class.reporter.publish(self, result)
  end

  def admin_user?
    !!context[:user]&.is_admin?
  end

  ## PROVIDE THE MISSING SCIENTIST GEM PUBLIC API
  def context(context); end

  def use; end

  def try; end

  def run(run); end
end
