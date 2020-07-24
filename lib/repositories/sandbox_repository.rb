# frozen_string_literal: true

require 'entities/sandbox'

module Repositories
  class SandboxRepository
    attr_reader :redis
    private :redis

    def initialize(redis)
      @redis = redis
    end

    def save(entity)
      redis.multi do
        redis.set("#{entity.email}:instance_uuid", entity.instance_uuid)
        redis.set("#{entity.email}:created_at", entity.created_at)
        redis.set("#{entity.email}:lifetime", entity.lifetime)
        redis.set("#{entity.email}:active", entity.active)
      end
    end

    def find_by_email(email)
      uuid = redis.get("#{email}:instance_uuid")
      if uuid
        Entities::Sandbox.new(email: email, instance_uuid: uuid,
                    created_at: redis.get("#{email}:created_at"),
                    lifetime: redis.get("#{email}:lifetime"),
                    active: redis.get("#{email}:active"))
      else
        nil
      end
    end

    def all
      _, email_keys = redis.scan(0, match: '*:instance_uuid')
      emails = email_keys.map { |k| k.split(':')[0] }
      emails.each_with_object([]) do |email, memo|
        memo << find_by_email(email)
      end
    end

    def overdue
      all.select do |sandbox|
        sandbox.active && sandbox.overdue?
      end
    end
  end
end
