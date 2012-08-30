require 'dl/import'

module USBRH
  extend DL::Importer
  dlload "USBMeter.dll"
  extern "char *_FindUSB(long *)"
  extern "long _GetTempHumid(char *, double *, double *)"
  extern "long _SetHeater(char *, long)"
  extern "long _ControlIO(char *, long, long)"
  extern "char *_GetVers(char *)"
  extern "long _GetTempHumidTrue(char *, double *, double *)"
end

class RHDevices
  def initialize
    index = [0].pack('l')
    @devices = {}
    while true
      current_index = index.unpack('l')[0]
      current_device = USBRH._FindUSB(index)
      break if current_device.to_s == ""
      @devices[current_index] = current_device
    end
  end

  def size
    @devices.size
  end

  def each
    @devices.each{|index,device|
      yield(RHDevice.new(device))
    }
  end
end

class RHDevice
  def initialize(device)
    @device=device
    @temperature = [0].pack('d')
    @humidity = [0].pack('d')
    @heater=false
    @led0=false
    @led1=false
  end

  def name
    @device.to_s
  end

  def version
    USBRH._GetVers(@device).to_s
  end

  def getTempHumid
    if USBRH._GetTempHumid(@device, @temperature, @humidity) == 0
      return @temperature.unpack('d')[0], @humidity.unpack('d')[0]
    else
      return nil,nil
    end
  end

  def getTempHumidTrue
    if USBRH._GetTempHumidTrue(@device, @temperature, @humidity) == 0
      return @temperature.unpack('d')[0], @humidity.unpack('d')[0]
    else
      return nil,nil
    end
  end

  def heater=(flag)
    if flag == true
      USBRH._SetHeater(@device, 1)
    elsif flag == false
      USBRH._SetHeater(@device, 0)
    else
      raise TypeError
    end
    @heater = flag
  end
  attr_reader :heater

  def led0=(flag)
    if flag == true
      USBRH._ControlIO(@device, 0, 1)
    elsif flag == false
      USBRH._ControlIO(@device, 0, 0)
    else
      raise TypeError
    end
    @led0 = flag
  end
  attr_reader :led0

  def led1=(flag)
    if flag == true
      USBRH._ControlIO(@device, 1, 1)
    elsif flag == false
      USBRH._ControlIO(@device, 1, 0)
    else
      raise TypeError
    end
    @led1 = flag
  end
  attr_reader :led1

end

=begin
rhdevices=RHDevices.new
rhdevices.each{|device|
  t,h = device.getTempHumid
  puts "name                 : #{device.name}"
  puts "version              : #{device.version}"
  puts "temperature          : #{t}"
  puts "humidity             : #{h}"
  t,h = device.getTempHumidTrue
  puts "corrected temperature: #{t}"
  puts "corrected humidity   : #{h}"
  device.led0=true
  sleep 1
  device.led0=false
  sleep 1
  device.led1=true
  sleep 1
  device.led1=false
  device.heater=true
  sleep 10
  t,h = device.getTempHumid
  puts "temperature : #{t}"
  puts "humidity    : #{h}"
  device.heater=false
}
=end
