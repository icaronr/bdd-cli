module TestGenerator
  module TempReader
    def read_temp_file(klass)
      file_path = Rails.root.join("tmp/BDD_#{klass}.json")

      return false unless File.exists?(file_path)

      JSON.parse(File.read(file_path))
    end
  end
end
