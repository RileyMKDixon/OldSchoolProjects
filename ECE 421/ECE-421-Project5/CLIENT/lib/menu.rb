require 'gtk3'
require "test/unit"
include Test::Unit::Assertions

require_relative 'game.rb'
require_relative 'board_view.rb'
require_relative 'menu_view.rb'

class Menu < Gtk::Application


    def initialize()
        super("org.ece421.connect", :flags_none)
        
        signal_connect "activate" do |application|
            menu_window = MenuWindow.new("../ui/menu_grid.glade", application)
            menu_window.show_all
        end
    end

end