require 'test/unit'
require_relative '../ruby_shell.rb'
require_relative '../tools.rb'

class FileManipulationTests < Test::Unit::TestCase

    def setup()
        RubyShell.make_file(["oldFile.txt"])
        RubyShell.make_directory(["oldDir"])
    end

    def test_create_folder()
        RubyShell.make_directory(["testDir"])
        assert_true(Dir::exist?("testDir"))

    end

    def test_delete_folder()
        RubyShell.remove_directory(["oldDir"])
        assert_false(Dir::exist?("oldDir"))
    end

    def test_create_file()
        RubyShell.make_file(["test.txt"])
        assert_true(File::exist?("test.txt"))
    end

    def test_delete_file()
        RubyShell.remove_file(["oldFile.txt"])
        assert_false(File::exist?("oldFile.txt"))
    end

    def test_directory_permissions()
        set_perms = Tools.gen_permissions()
        RubyShell.make_file(["-p", set_perms, "test.txt"])
        RubyShell.make_directory(["-p", set_perms, "testDir"])
        assert_true(File::exist?("test.txt"))
        assert_true(Dir::exist?("testDir"))
    end


    def teardown()
        RubyShell.remove_directory(["testDir"])
        RubyShell.remove_file(["test.txt"])
        RubyShell.remove_directory(["oldDir"])
        RubyShell.remove_file(["oldFile.txt"])
    end


end