# frozen_string_literal: true

module Services
  class StopOverdueSandboxesService
    attr_reader :sandbox_repo

    def initialize(sandbox_repo)
      @sandbox_repo = sandbox_repo
    end

    def call
      stopped = []
      failed = []
      sandbox_repo.overdue.each do |sandbox|
        script = Entities::Script.load(
          path: File.join(LIB_PATH, 'scripts', 'stop_sandbox.sh'),
          variables: {
            token: sandbox.instance_uuid,
            sandbox_dir: "#{ROOT_PATH}/sandbox",
            nginx_dir: "#{ROOT_PATH}/nginx_conf"
          }
        )
        run_successfully = script.run

        if run_successfully
          sandbox.inactivate
          sandbox_repo.save(sandbox)
          stopped << sandbox
        else
          failed << sandbox
        end
      end

      {
        success: true,
        data: { stopped: stopped.map(&:to_h), failed: failed.map(&:to_h) }
      }
    end
  end
end
