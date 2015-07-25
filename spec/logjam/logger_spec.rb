require "spec_helper"

describe LogJam::Logger do
	let(:temp_dir) {
		File.join(Dir.getwd, "spec", "tmp")
	}

	before do
		Dir.mkdir(temp_dir) if !File.exist?(temp_dir)
	end

	after do
		Dir.glob(File.join(temp_dir, "*")).each {|file| File.delete(file)}
		Dir.rmdir(temp_dir)
	end

	describe "#initialize()" do
		subject {
			LogJam::Logger
		}

		it "can be passed an IO object" do
			expect {
				logger = subject.new(STDOUT)
			}.not_to raise_exception
		end

		it "can be passed a string file name" do
			expect {
				logger = subject.new(File.join(Dir.getwd, "spec", "tmp", "test.log"))
			}.not_to raise_exception
		end

    it "can be passed a standard logger" do
			expect {
				logger = subject.new(Logger.new(STDOUT))
			}.not_to raise_exception
		end

		it "raises an exception if passed an invalid file name" do
			path = File.join(Dir.getwd, "spec", "non_existent", "test.log")
			expect {
				subject.new(path)
			}.to raise_exception(StandardError, "No such file or directory @ rb_sysopen - #{path}")
		end
	end

	describe "#name" do
		subject {
			LogJam::Logger.new(STDOUT)
		}

		it "returns nil if the logger hasn't been assigned a name" do
			expect(subject.name).to be_nil
		end

		it "returns the correct name for a logger once assigned" do
			subject.name = "ATestLogger"
			expect(subject.name).to eq("ATestLogger")
		end
	end

	describe "#name=()" do
		subject {
			LogJam::Logger.new(STDOUT)
		}

    it "allows the assignment and alteration of a logger name" do
			subject.name = "Test Name"
			expect(subject.name).to eq("Test Name")
			subject.name = "Different Name"
			expect(subject.name).to eq("Different Name")
		end
	end

	describe "#logger()" do
		subject {
			LogJam::Logger.new(STDOUT)
		}

		it "provides access to the wrapped logger" do
			expect(subject.logger).not_to be_nil
			expect(subject.logger.class).to eq(Logger)
		end
	end

	describe "#logger=()" do
		subject {
			LogJam::Logger.new(STDOUT)
		}

		it "permits the alteration of the wrapper logger" do
			logger = subject.logger
			subject.logger = Logger.new(STDERR)
			expect(logger).not_to eq(subject.logger)
		end
	end

  describe "forwarded elements of the class" do
		subject {
			LogJam::Logger.new(STDOUT)
		}
		let(:logger) {
			subject.logger
		}

		it "delegates method calls on to the wrapped logger instance" do
			expect(logger).to receive(:level).and_return("Blah")
			expect(logger).to receive(:level=).with(Logger::FATAL)
			expect(subject.level).to eq("Blah")
			subject.level = Logger::FATAL
		end
	end
end
