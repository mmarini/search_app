module StringHelper

  # This has been taken from the Active Support `underscore` method
  def underscore(string)
    return nil if string.nil?

    string.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
  end

end