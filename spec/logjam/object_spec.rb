require "spec_helper"

describe Object do
	let(:configuration) {
		{loggers: [{default: true, file: "STDOUT", name: "first"},
			         {file: "STDERR", name: "second"}]}
	}

	before do
		LogJam.configure(configuration)
	end

	after do
		LogJam.configure
	end

	it "applies a log method that returns a logger to the Object class" do
		expect(Object.log.class).to eq(LogJam::Logger)
	end

	it "a log method that returns a logger is available from all Object derived classes" do
		expect("text".log.class).to eq(LogJam::Logger)
	end

	it "allows the underlying default logger to be altered" do
		loggers    = [String.log, Logger.new(STDERR)]
		String.log = loggers[1]
		expect(String.log.logger).to eq(loggers[1])
	end

	it "allows the logger for a specific class to be altered" do
		String.set_logger_name "second"
		expect(String.log).to eq(LogJam.get_logger("second"))
		expect(Object.log).to eq(LogJam.get_logger("first"))
	end
end
