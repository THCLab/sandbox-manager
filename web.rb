require 'redis'
require 'roda'

class Web < Roda
  plugin :json

  redis = Redis.new(host: 'tda-init-redis', port: 6379)
  sandbox_repo = Repositories::SandboxRepository.new(redis)
  mailer = Mailer.new(YAML.load_file(File.join(__dir__, 'config', 'mail.yml')))

  route do |r|
    r.on 'api' do
      r.on 'v1' do
        r.on 'run' do
          r.post do
            service = ::Services::RunSandboxService.new(sandbox_repo, mailer)
            service.call(r.params)
          end
        end

        r.on 'stop-overdue' do
          r.get do
            service = ::Services::StopOverdueSandboxesService.new(sandbox_repo)
            service.call
          end
        end
      end
    end
  end
end
