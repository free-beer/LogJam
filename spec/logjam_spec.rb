require "spec_helper"

describe LogJam do
  let(:configuration) {
    {loggers: [{default: true, file: "STDOUT", name: "stdout"},
               {file: "STDERR", name: "stderr"}]}
  }
  subject {
    LogJam
  }

  describe "#configure()" do
    after do
      LogJam.configure
    end

    describe "when passed a Hash parameter" do
      it "configures LogJam based on the details in the Hash" do
        LogJam.configure(configuration)
        expect(LogJam.get_logger("stdout")).not_to be_nil
        expect(LogJam.get_logger("stderr")).not_to be_nil
        expect(LogJam.get_logger("stdout")).not_to eq(LogJam.get_logger("stderr"))
      end
    end

    describe "when called without parameters" do
      it "applies the default configuration loaded from available files" do
        LogJam.configure(configuration)
        LogJam.configure
        expect(LogJam.get_logger("testlog")).not_to be_nil
        expect(LogJam.get_logger).not_to eq(LogJam.get_logger("testlog"))
      end
    end
  end

  describe "#get_logger()" do
    before do
      LogJam.configure(configuration)
    end

    after do
      LogJam.configure
    end

    it "returns the default logger when called with no parameters" do
      expect(LogJam.get_logger).to eq(LogJam.get_logger("stdout"))
    end

    it "returns the named logger when called with a logger name" do
      expect(LogJam.get_logger("stderr")).not_to eq(LogJam.get_logger)
    end
  end

  describe "#names()" do
    before do
      LogJam.configure(configuration)
    end

    after do
      LogJam.configure
    end

    it "returns a list of the configured logger names" do
      expect(LogJam.names.class).to eq(Array)
      expect(LogJam.names.size).to eq(2)
      expect(LogJam.names).to include("stdout")
      expect(LogJam.names).to include("stderr")
    end
  end

  describe "#create_logger()" do
    it "creates an instance of the LogJam::Logger class when given valid inputs" do
      logger = LogJam.create_logger({})
      expect(logger.class).to eq(LogJam::Logger)
    end
  end
end
