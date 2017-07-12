json.extract! handler, :id, :repo_path, :local_path, :short_name, :name, :created_at, :updated_at
json.url handler_url(handler, format: :json)
