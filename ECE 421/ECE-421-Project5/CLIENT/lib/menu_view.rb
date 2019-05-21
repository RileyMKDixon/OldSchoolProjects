require "gtk3"

class MenuWindow < Gtk::ApplicationWindow
    type_register
    class << self
        def init
        end
    end

    def play_callback(_widget)
        if @rows < 1 || @cols < 1
            # TODO Display an error
            p "Rows or cols not greater than 0"
            return
        end
        hide
        Game.instance.setup(@player_count, [@p1Token, @p2Token], [@p1Pattern, @p2Pattern], [@p1Colour, @p2Colour], @rows, @cols)
        game_window = Game.instance.make_board()
        game_window.signal_connect "delete-event" do |_widget|
            game_window.destroy
            show_all
        end
        game_window.show_all
    end

    def players_callback(_widget)
        # When changing radio buttons, both run the toggled callback
        # We only care about the one that is active
        if _widget.active?()
            if _widget.builder_name == "radio_one_player"
                # p "One player"
                @player_count = 1
            elsif _widget.builder_name == "radio_two_player"
                # p "Two player"
                @player_count = 2
            end
        end
    end

    def rows_lost_focus(_widget, event)
        begin
            if Integer(_widget.text()) > 0
                @rows = Integer(_widget.text())
                check_pattern_length()
                return
            end
        rescue
        end
        p "Error in setting rows"
        _widget.set_text("Invalid Value")
    end

    def cols_lost_focus(_widget, event)
        begin
            if Integer(_widget.text()) > 0
                @cols = Integer(_widget.text())
                check_pattern_length()
                return
            end
        rescue
        end
        p "Error in setting cols"
        _widget.set_text("Invalid Value")
    end

    def check_pattern_length()
        p1PatternWidget = @widgetBuilder.get_object("entry_p1_pattern")
        p2PatternWidget = @widgetBuilder.get_object("entry_p2_pattern")
        if @p1Pattern.length > @rows && @p1Pattern.length > @cols
            @p1Pattern = ""
            [@rows, @cols].max.times{@p1Pattern = @p1Pattern + @p1Token}
            p1PatternWidget.set_text(@p1Pattern)
        end
        if @p2Pattern.length > @rows && @p2Pattern.length > @cols
            @p2Pattern = ""
            [@rows, @cols].max.times{@p2Pattern = @p2Pattern + @p2Token}
            p2PatternWidget.set_text(@p2Pattern)
        end
    end


    def colourblind_lost_focus(comboBoxText)
        #puts Gtk::ComboBoxText.instance_methods #helpful if you want to see methods. Base methods display first and then inherited methods.
        comboMenuGetID = comboBoxText.active_id()
        begin
            if comboMenuGetID == "0"
                @p1Colour = Gdk::RGBA.new(1, 0, 0, 1) #Red
                @p2Colour = Gdk::RGBA.new(1, 1, 0, 1) #Yellow
            elsif comboMenuGetID == "1"
                @p1Colour = Gdk::RGBA.new(1, 0, 0, 1) #Red
                @p2Colour = Gdk::RGBA.new(0, 0, 1, 1) #Blue
            elsif comboMenuGetID == "2"
                @p1Colour = Gdk::RGBA.new(1, 0, 0, 1) #Red
                @p2Colour = Gdk::RGBA.new(0, 1, 0, 1) #Green
            elsif comboMenuGetID == "3"
                @p1Colour = Gdk::RGBA.new(0.75, 0.75, 0.75, 1) #1/4 grey
                @p2Colour = Gdk::RGBA.new(0.25, 0.25, 0.25, 1) #3/4 grey
            else
                puts "Im not sure how we got here"
                raise StandardError
            end
        rescue

        end

    end

    def p1_token_lost_focus(entryView, event)
        entryViewText = entryView.text()
        begin
            if(entryViewText.length != 1)
                raise StandardError
            end
            @p1Token = entryViewText
            
            p1PatternWidget = @widgetBuilder.get_object("entry_p1_pattern")
            @p1Pattern = ""
            [[@rows, @cols].max, 4].min.times{@p1Pattern = @p1Pattern + @p1Token}
            p1PatternWidget.set_text(@p1Pattern)

        rescue
            entryView.set_text("Invalid Token")
        end
    end

    def p2_token_lost_focus(entryView, event)
        entryViewText = entryView.text
        begin
            if(entryViewText.length != 1)
                raise StandardError
            end
            @p2Token = entryViewText

            p2PatternWidget = @widgetBuilder.get_object("entry_p2_pattern")
            @p2Pattern = ""
            [[@rows, @cols].max, 4].min.times{@p2Pattern = @p2Pattern + @p2Token}
            p2PatternWidget.set_text(@p2Pattern)

        rescue
            entryView.set_text("Invalid Token")
        end
    end

    def p1_pattern_lost_focus(entryView, event)
        entryViewText = entryView.text
        begin
            if(entryViewText.length > 10 || entryViewText.length < 1)
                entryView.set_text("Invalid Pattern")
                raise StandardError
            end
            if(entryViewText.length > @rows && entryViewText.length > @cols)
                entryView.set_text("Board Size Too Small")
                raise StandardError
            end

            usingValidChars = entryViewText.gsub(/[#{Regexp.escape(@p1Token)}#{Regexp.escape(@p2Token)}]/, "").strip
            if(!usingValidChars.eql?(""))
                entryView.set_text("NonToken char used.")
                raise StandardError
            end


            @p1Pattern = entryViewText
        rescue
        end
    end

    def p2_pattern_lost_focus(entryView, event)
        entryViewText = entryView.text()
        begin
            if(entryViewText.length > 10 || entryViewText.length < 1)
                entryView.set_text("Invalid Pattern")
                raise StandardError
            end
            if(entryViewText.length > @rows && entryViewText.length > @cols)
                entryView.set_text("Board Size Too Small")
                raise StandardError
            end
            @p2Pattern = entryViewText
        rescue
        end
    end

    def initialize(layout, application)
        super(:application => application)
        set_title("Connect 4 - Menu")
        build(layout)
        @player_count = 2
        @rows = 6
        @cols = 7
        @p1Token = "R"
        @p2Token = "Y"
        @p1Pattern = "RRRR"
        @p2Pattern = "YYYY"
        @p1Colour = Gdk::RGBA.new(1, 0, 0, 1) #Default to Normal
        @p2Colour = Gdk::RGBA.new(1, 1, 0, 1) #Default to Normal
    end

    def build(filepath)
        builder_file = "#{File.expand_path(File.dirname(__FILE__) )}/#{filepath}"
        builder = Gtk::Builder.new(:file => builder_file)
        @widgetBuilder = builder #So we can access other widgets during events
        builder.connect_signals do |handler|
            method(handler)
        end

        add(builder.get_object("grid_menu"))
    end

end