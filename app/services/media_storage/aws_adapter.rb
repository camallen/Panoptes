module MediaStorage
  class AwsAdapter < AbstractAdapter
    attr_reader :prefix, :s3, :get_expiration, :put_expiration
    DEFAULT_EXPIRES_IN = 180

    def initialize(opts={})
      @prefix = opts[:prefix] || Rails.env
      @bucket_name = opts[:bucket]
      @get_expiration = opts.dig(:expiration, :get) || DEFAULT_EXPIRES_IN
      @put_expiration = opts.dig(:expiration, :put) || DEFAULT_EXPIRES_IN
    end

    # this will generate a location path to store data in the storage provider
    def stored_path(content_type, medium_type, *path_prefix)
      extension = get_extension(content_type)
      path = prefix.to_s
      path += "/" unless path[-1] == '/'
      path += "#{medium_type}/"
      path += "#{path_prefix.join('/')}/" unless path_prefix.empty?
      path += "#{SecureRandom.uuid}.#{extension}"
      path
    end

    def get_path(path, opts={})
      "https://#{path}"
    end

    def put_path(path, opts={})
      ## Removed - ensure we don't attempt to communicate with the s3 service
      ## this will break the PFE media uploading

      # this could be modified to return an upload location to an uploadable
      # location for the credit-suisse team
    end

    def put_file(path, file_path, opts={})
    true
    end

    ## Ensure we raise errors if we try and use the encrypted bucket
    def encrypted_bucket?
      false
    end
  end
end
