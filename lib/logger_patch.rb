class Logger
  alias :write :'<<'

  class LogDevice
    private
    alias_method :open_logfile_org, :open_logfile
    alias_method :create_logfile_org, :create_logfile
    alias_method :shift_log_period_org, :shift_log_period

    def open_logfile(filename)
      if (FileTest.exist?(filename))
        open(filename, (File::WRONLY | File::APPEND), 0666)
      else
        create_logfile(filename)
      end
    end

    def create_logfile(filename)
      logdev = open(filename, (File::WRONLY | File::APPEND | File::CREAT), 0666)
      logdev.sync = true
      add_log_header(logdev)
      logdev
    end

    def shift_log_period(period_end)
      postfix = period_end.strftime("%Y%m%d") # YYYYMMDD
      age_file = "#{@filename}.#{postfix}"
      if FileTest.exist?(age_file)
        @dev.close
        if FileTest.exist?(@filename)
          @dev = open_logfile(@filename)
        else
          @dev = create_logfile(@filename)
        end
        return true
      end
      @dev.close rescue nil
      File.rename("#{@filename}", age_file)
      @dev = create_logfile(@filename)
      return true
    end
  end
end
