module Tools
  def self.gen_permissions
    ((rand(0..7) * 100) + (rand(0..7) * 10) + rand(0..7)).to_s.rjust(3, '0')
  end
end
