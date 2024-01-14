Rails.application.configure do
  config.good_job.enable_cron = true
  config.good_job.cron = {
    sync_data_job: {
      class: 'SyncDataJob',
      cron: 'Every hour',
      description: 'Pull pricing data from Royal Caribbean'
    }
  }
end