# frozen_string_literal: true

require 'entities/sandbox'
require 'json'

module Repositories
  class SandboxRepository
    attr_reader :redis
    private :redis

    def initialize(redis)
      @redis = redis
    end

    def save(entity)
      entity_json = entity.to_h.slice(
        :email, :instance_uuid, :created_at, :lifetime
      ).to_json

      redis.multi do
        redis.set("#{entity.email}:instance_uuid", entity.instance_uuid)
        redis.set("#{entity.email}:created_at", entity.created_at)
        redis.set("#{entity.email}:lifetime", entity.lifetime)
        redis.set("#{entity.email}:active", entity.active)

        if entity.active
          redis.rpush('active_sandboxes', entity_json)
          redis.incr('active_sandboxes_counter')
        else
          redis.lrem('active_sandboxes', 1, entity_json)
          redis.decr('active_sandboxes_counter')
        end
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

    def count_active
      redis.get('active_sandboxes_counter').to_i || 0
    end

    def overdue
      active_sandboxes = redis.lrange('active_sandboxes', 0, -1).map do |json|
        sandbox_hash = JSON.parse(json, symbolize_names: true)
        Entities::Sandbox.new(sandbox_hash.merge(active: true))
      end
      active_sandboxes.select(&:overdue?)
    end
  end
end
