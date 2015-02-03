class RegistrationsController < Devise::RegistrationsController
  include JSONApiRender

  def create
    respond_to do |format|
      format.json { create_from_json }
      format.html { super }
    end
  end

  private

  def create_from_json
    resource_saved = ActiveRecord::Base.transaction(requires_new: true) do
      build_resource(sign_up_params)
      raise ActiveRecord::Rollback unless resource.save
    end
    yield resource if block_given?
    status, content = registrations_response(resource_saved)
    clean_up_passwords resource
    render status: status, json_api: content
  end

  def build_resource(sign_up_params)
    super(sign_up_params)
    login = sign_up_params[:login]
    resource.display_name = login
    resource.login = login
    resource.build_identity_group
  end

  def registrations_response(resource_saved)
    if resource_saved
      sign_in resource, event: :authentication
      resource_scope = resource.class.where(id: resource.id)
      [ :created, UserSerializer.resource({}, resource_scope, { include_private: true }) ]
    else
      response_body = {}
      if resource && !resource.valid?
        response_body.merge!({ errors: [ message: resource.errors ] })
      end
      [ :unprocessable_entity, response_body ]
    end
  end
end
