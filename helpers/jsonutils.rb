module JsonUtils
  def json_status(code, message='')
    status code
    { :status => code, :message => message }.to_json
  end
end
