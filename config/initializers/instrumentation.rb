ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
  req = payload[:request]
  msg = [req.env['rack.attack.match_type'], req.ip, req.request_method, req.fullpath, ('"' + req.user_agent.to_s + '"')].join(' ')
  if [:throttle, :blocklist].include? req.env['rack.attack.match_type']
    Rails.logger.error(msg)
  else
    Rails.logger.info(msg)
  end
end
