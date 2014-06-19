module APIResponseHelpers
  def json_response
    @json ||= JSON.parse(response.body)
  end

  def json_error_message(error_message)
    { errors: [ message: error_message ] }.to_json
  end
end

module APIRequestHelpers
  def set_accept
    request.headers["Accept"] = "application/vnd.api+json; version=1"
  end

  def set_patch_content_type
    request.headers["Content-Type"] = "application/json-patch"
  end

  def stub_token(scopes: [], user_id: nil)
    allow(controller).to receive(:doorkeeper_token) { double( accessible?: true,
                                                              scopes: scopes,
                                                              acceptable?: true,
                                                              resource_owner_id: user_id ) }
  end

  def stub_token_with_scopes(*scopes)
    stub_token(scopes: scopes)
  end

  def stub_token_with_user(user)
    stub_token(user_id: user.id)
  end

  def default_request(scopes: ["public"], user_id: nil)
    set_accept
    stub_token(scopes: scopes, user_id: user_id)
  end
end
