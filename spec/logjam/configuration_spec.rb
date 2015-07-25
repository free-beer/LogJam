require 'spec_helper'

describe LogJam::Configuration do
  it "auto-loads the logging configuration from ./config/logging.yml" do
    expect(LogJam::Configuration["loggers"]).not_to be_nil
    expect(LogJam::Configuration.loggers).to be_instance_of(Array)
  end

  it "picks up the correct environment" do
    expect(LogJam::Configuration.loggers.first["name"]).not_to be_nil
    expect(LogJam::Configuration.loggers.first["name"]).to eq("testlog")
  end
end
