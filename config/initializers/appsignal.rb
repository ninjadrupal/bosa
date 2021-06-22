# frozen_string_literal: true

Appsignal::Minutely.probes.register :web_app_probe, lambda {
  Appsignal.set_gauge("database_size", 10)
}
