# frozen_string_literal: true

module Services
  class RunSandboxService
    def call
      token = generate_token
      script = load_script(
        path: File.join(LIB_PATH, 'scripts', 'run_sandbox.sh'),
        variables: {
          token: token,
          sandbox_dir: "#{ROOT_PATH}/sandbox",
          templates_dir: "#{ROOT_PATH}/templates"
        }
      )
      result = %x(#{script})
      puts result.split('\n')

      {
        success: true,
        data: {
          token: token
        }
      }
    end

    private def generate_token
      rand(36**6).to_s(36)
    end

    private def load_script(path:, variables:)
      script = File.read(path)
      variables.each do |k, v|
        script.gsub!("%{#{k.upcase}}", v)
      end
      script
    end
  end
end