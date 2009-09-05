module Watchr
  class Controller

    def initialize(script)
      @script = script
    end

    def run
      @handler = Watchr.event_handler.new
      @handler.add_observer(self)
      @handler.listen(monitored_paths)
      run
    end

    def monitored_paths
      paths = Dir['**/*'].select do |path|
        @script.patterns.any? {|p| path.match(p) }
      end
      paths.push(@script.path).compact!
      paths.map {|path| Pathname(path).expand_path }
    end

    # callback
    #
    # @see EventHandler#notify
    # @see corelib, Observable
    #
    # TODO handle event types.
    # TODO build array of recognized event types.
    #
    #   Controller.event_types = [:changed, :moved, :deleted, etc]
    #
    def update(path, event = nil)
      path = Pathname(path).expand_path

      if path == @script.path
        @script.parse!
        @handler.terminate!
      else
        @script.action_for(path).call
      end
    end
  end
end

