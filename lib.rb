require 'fileutils'

def arg_check(path_to_shapefiles)
  unless path_to_shapefiles
    STDERR.puts("Error: Missing path to shape file argument.")
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

def base_path(path_to_shapefiles)
  sep = path_to_shapefiles.split("/"); sep.pop
  path = sep.join("/")
end

def base_name(path_to_shapefiles)
  bname = path_to_shapefiles.split("/")[-1].sub('.shp', '')
end

# standardize filenames to lowercase
def rename_shapefiles(path_to_shapefiles)
  files = Dir.glob(path_to_shapefiles + '*').select { |f| File.file?(f) }
  files.each { |f| FileUtils.mv(f, f.gsub(' ', '').downcase)  unless f == f.gsub(' ', '').downcase }
end

# mapshaper only simplifies some files, losing meta data
# copying remaining files w/same basenames restores meta data
def copy_nonsimplified_files(path_to_shapefiles)
  extensions = ['.cpg', '.sbn', '.sbx', '.shp.xml']
  extensions.each do |e|
    path = base_path(path_to_shapefiles)
    file = Dir.glob(path + "/" + '*' + e)[0]
    unless file.nil? || file.empty?
      FileUtils.cp(file, path + "/" + File.basename(file, e) + '_simplified' + e)
    end
  end
end

def simplify_shapefiles(path_to_shapefiles, percent)
  shapefile = Dir.glob(path_to_shapefiles + '*.shp')[0]
  path = base_path(path_to_shapefiles)
  `mapshaper #{shapefile} auto-snap -simplify keep-shapes #{percent}% -o force #{path + "/" + File.basename(shapefile, '.shp') + "_simplified.shp"}`
  copy_nonsimplified_files(path_to_shapefiles)
end

def shape2json(path_to_shapefiles)
  path = base_path(path_to_shapefiles)
  bname = base_name(path_to_shapefiles)
  `ogr2ogr -f "GeoJSON" -t_srs EPSG:3857 #{path + "/" + bname}.geojson #{path + "/" + bname + ".shp"}`
end

def string_eval(string, properties)
  if string.include?("[")
    eval(string)
  else
    string
  end
end

def district_id2name(id, json_file, id_label, name_label)
  data = File.open(json_file).read
  json = JSON.parse(data)
  features = json['features']
  features.each do |feature|
    properties = feature["properties"]
    if id = properties[id_label]
      return properties[name_label]
      break
    end
  end
end
