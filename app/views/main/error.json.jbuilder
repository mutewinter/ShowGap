if @error
  json.error @error[:message]
elsif @errors
  json.errors @errors
end
