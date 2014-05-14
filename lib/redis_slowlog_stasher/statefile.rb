# TODO: if you give it a nil filename, read gives you 0,0, write is a noop?
class StateFile
  def initialize(filename)
    @filename = filename
  end

  def read
    File.open(@filename, 'r') do |state_file|
      state_file.gets.chomp.split(':').map(&:to_i)
    end
  rescue Errno::ENOENT
    # if the file doesn't exist, just return the thing
    [0,0]
  end

  def write(entry_timestamp, entry_id)
    File.open(@filename, 'w') do |state_file|
      state_file.puts("#{entry_timestamp}:#{entry_id}")
    end
  end
end
