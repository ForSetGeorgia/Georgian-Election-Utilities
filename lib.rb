require 'fileutils'

def arg_check(path_to_shapefiles)
  unless path_to_shapefiles
    STDERR.puts("Error: Missing path to shapefiles argument.")
    exit(false)
  end
end

def which(command)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{command}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

def check_dependencies(dependency_array)
   dependency_array.each do |d|
     unless which(d)
       STDERR.puts("Error: Install dependency #{d}.")
       exit(false)
     end
   end
end

def rename_shapefiles(path_to_shapefiles)
  files = Dir.glob(path_to_shapefiles + '*').select { |f| File.file?(f) }
  files.each { |f| FileUtils.mv(f, f.gsub(' ', '').downcase)  unless f == f.gsub(' ', '').downcase }
end

# mapshaper only simplifies some files, losing meta data
# copying remaining files w/same basenames restores meta data
def copy_nonsimplified_files(path_to_shapefiles)
  extensions = ['.cpg', '.sbn', '.sbx', '.shp.xml']
  extensions.each do |e|
    file = Dir.glob(path_to_shapefiles + '*' + e)[0]
    unless file.nil? || file.empty?
      FileUtils.cp(file, path_to_shapefiles + File.basename(file, e) + '_simplified' + e)
    end
  end
end

def simplify_shapefiles(path_to_shapefiles, percent)
  shapefile = Dir.glob(path_to_shapefiles + '*.shp')[0]
  `mapshaper #{shapefile} auto-snap -simplify #{percent}% -o force #{path_to_shapefiles + File.basename(shapefile, '.shp') + "_simplified.shp"}`
  copy_nonsimplified_files(path_to_shapefiles)
end

def shape2json(path_to_shapefiles)
  shapefile = Dir.glob(path_to_shapefiles + '*_simplified.shp')[0]
  bname = File.basename(shapefile, '.shp')
  `ogr2ogr -f GeoJSON -t_srs crs:84 #{path_to_shapefiles + bname}.geojson #{shapefile}`
end
