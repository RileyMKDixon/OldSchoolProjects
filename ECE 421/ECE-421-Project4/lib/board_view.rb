require "test/unit"
include Test::Unit::Assertions

require_relative "game.rb"
require "gtk3"

class BoardWindow < Gtk::ApplicationWindow
    type_register
    class << self
        def init
        end
    end

    def token_callback(_widget, event)
        # Double/Triple clicking yield an exta event each:
        # BUTTON2_PRESS and BUTTON3_PRESS respectively
        if event.event_type != Gdk::EventType::BUTTON_PRESS
            # print "Not button press, instead got "
            # p event.event_type
            return
        end
        # p "#{_widget.builder_name} sent a signal!"
        name_arr = _widget.builder_name.split(' ')
        col = name_arr[-1].to_i

        if !Game.instance.game_over
            Game.instance.add_token(col)
        end
        return true
    end

    def quit_callback
        close
    end

    def initialize(rows, cols, layout_file, background_file)
        super()
        set_title("Connect 4 - Game")
        @rows = rows
        @cols = cols
        @board_grid = nil
        @background = GdkPixbuf::Pixbuf.new(file: "#{File.expand_path(File.dirname(__FILE__) )}/#{background_file}")
        build(layout_file)
        realize
        set_default_size([@cols, 15.5].min()*75 + 2, [@rows, 10.5].min()*75 + @builder.get_object("button_quit").allocation.height + 2)
    end

    def build(filepath)
        builder_file = "#{File.expand_path(File.dirname(__FILE__) )}/#{filepath}"
        @builder = Gtk::Builder.new(:file => builder_file)

        @builder.connect_signals do |handler|
            method(handler)
        end

        @board_grid = @builder.get_object("grid_board")

        (0..@cols - 1).each do |j|
            (0..@rows - 1).each do |i|
                img = Gtk::Image.new(pixbuf: @background)
                event_box = Gtk::EventBox.new.add(img)
                event_box.set_size_request(75, 75)
                event_box.signal_connect("button-press-event") { |_widget, event| token_callback(_widget, event) }
                event_box.override_background_color(:normal, Gdk::RGBA.new(1, 1, 1, 1))
                event_box.set_border_width(0)
                @builder.expose_object("Row " + i.to_s + " Col " + j.to_s, event_box)
                @board_grid.attach(event_box, j, i, 1, 1)
            end
        end
        add(@builder.get_object("grid_main"))
    end

    def set_info(info)
        lbl = @builder.get_object("label_info")
        lbl.set_text(info)
        lbl.queue_draw
        redraw
    end

    def redraw()
        while Gtk.events_pending?
            Gtk.main_iteration
        end
    end

    def update(row, col, token)
        # Draw token at row, col
        assert(col >= 0)
        assert(row >= 0)
        assert(col < @cols)
        assert(row < @rows)

        place = @builder.get_object("Row " + (@rows - row - 1).to_s + " Col " + col.to_s)
        place.override_background_color(:normal, token.color)
        place.queue_draw
    end
end
