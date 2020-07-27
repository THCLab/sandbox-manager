require 'services/run_sandbox_service'
require 'services/stop_overdue_sandboxes_service'

require 'entities/script'
require 'entities/sandbox'

require 'repositories/sandbox_repository'

require 'mailer'

SANDBOX_PATH = ENV['SANDBOX_PATH'] || ''
INSTANCES_LIMIT = ENV['INSTANCES_LIMIT'].to_i || 0
