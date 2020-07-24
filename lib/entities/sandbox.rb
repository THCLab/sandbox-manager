# frozen_string_literal: true

require 'securerandom'

module Entities
  class Sandbox
    attr_reader :email, :instance_uuid, :created_at, :lifetime, :active

    def initialize(email:, instance_uuid:, created_at:, lifetime:, active:)
      @email = email
      @instance_uuid = instance_uuid
      @created_at = Time.parse(created_at.to_s)
      @lifetime = lifetime.to_i
      @active = active.to_s == 'true'
    end

    class << self
      def create(email:)
        new(email: email,
            instance_uuid: generate_uuid,
            created_at: Time.now,
            lifetime: 24*3600,
            active: true)
      end

      private def generate_uuid
        SecureRandom.uuid
      end
    end

    def inactivate
      @active = false
    end

    def overdue?
      created_at + lifetime < Time.now
    end

    def to_h
      {
        email: email,
        instance_uuid: instance_uuid,
        created_at: created_at,
        lifetime: lifetime,
        active: active
      }
    end
  end
end
