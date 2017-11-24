class StatusesController < ApplicationController

  def show
    check_database
    check_sidekiq_redis
    head :ok
  end

  private

  def check_database
    ActiveRecord::Migrator.current_version
  end

  def check_sidekiq_redis
    Sidekiq.redis(&:info)
  end

end