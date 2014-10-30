module JsonApiRoutes
  def id_constraint(path)
    { :"#{ path.to_s.singularize }_id" => /[0-9]*/ }
  end
  
  def create_links(path, links)
    links_regex = /(#{ links.map(&:to_s).join('|') })/
    constraints = { link_relation: links_regex }.merge(id_constraint(path))
    
    post "/links/:link_relation", to: "#{ path }#update_links",
      constraints: constraints, format: :false
    
    delete "/links/:link_relation/:link_ids", to: "#{ path }#update_links",
      constraints: constraints, format: :false
  end
  
  def json_api_resources(path, options={})
    links = options.delete(:links)
    options = options.merge(except: [:new, :edit],
                            constraints: { id: /[0-9]*/ },
                            format: false)
    resources(path, options) do
      create_links(path, links) if links
      yield if block_given?
    end
  end
end
