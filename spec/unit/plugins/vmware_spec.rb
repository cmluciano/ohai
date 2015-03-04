require 'spec_helper'
require 'ohai/plugins/vmware'

describe Ohai::System, "plugin vmware" do
  let (:plugin) do
     plugin = get_plugin("vmware")
  end
  let(:path) { "blah" }

  context "path does not exist" do
    let(:error) { "not found" }
    before :each do
      File.stub(:exist?).and_return(false)
    end
    it "returns an object when given path" do
      Ohai::Log.should_receive(:debug).with(path + " #{error}")
      attributes = plugin.get_vm_attributes(path)
    end
  end

  context "path does exist" do
    let(:mix_lib) { double('Mixlib') }
    let(:command_output) do
        {"hosttime"   => nil,
          "speed"     => nil,
          "sessionid" => nil}
    end
    before :each do
      File.stub(:exist?).and_return(true)
      Mixlib.stub(:shell_out).and_return(mix_lib)
      mix_lib.stub(:stdout).and_return(command_output)
    end

    # context "testing from_cmd" do
      # let(:param) { "hosttime" }

      # it "calls from_cmd" do
        # plugin.should_receive(:from_cmd).exactly(1).times.with("#{path} stat #{param}")
        # plugin.get_vm_attributes(path)
      # end
    # end

    context "valid output" do
      let(:time_value)    { "time value" }
      let(:speed_value)   { "speed value" }
      let(:session_value) { "session value" }
      let(:command_output) do
        {"hosttime"   => time_value,
          "speed"     => speed_value,
          "sessionid" => session_value}
      end

      it "sets variables correctly" do
        vmware = plugin.get_vm_attributes(path)
        p vmware
        vmware[:'hosttime'].should eql(time_value)
        vmware[:'speed'].should eql(speed_value)
        vmware[:'sessionid'].should eql(session_value)
      end
    end

    context "invalid output" do
      let(:command_output) { "UpdateInfo failed" }

      it "sets vmware to nil if update info fails" do
        vmware = plugin.get_vm_attributes(path)
        vmware.map { |symbol| symbol.should be_nil }
      end
    end
  end
end
