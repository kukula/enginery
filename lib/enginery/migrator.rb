module Enginery
  class Migrator
    include Helpers

    TIME_FORMAT = '%Y-%m-%d_%H-%M-%S'.freeze
    NAME_REGEXP = /\A(\d+)\.(\d+\-\d+\-\d+_\d+\-\d+\-\d+)\.(.*)\.rb\Z/

    def initialize dst_root, setups
      @dst_root, @setups = dst_root, setups
      @migrations = Dir[dst_path(:migrations, '*.rb')].inject([]) do |map,f|
        step, time, name = File.basename(f).scan(NAME_REGEXP).flatten
        step && time && name && map << [step.to_i, time, name, f]
        map
      end.sort {|a,b| a.first <=> b.first}.freeze
    end

    # generate new migration.
    # it will create a [n].[timestamp].[name].rb migration file in base/migrations/
    # and column_transitions.yml file in base/migrations/track/
    # migration file will contain "up" and "down" sections.
    # column_transitions file will keep track of column type changes.
    def new name
      (name.nil? || name.empty?) && fail("Please provide migration name via second argument")
      (name =~ /[^\w|\d|\-|\.|\:]/) && fail("Migration name can contain only alphanumerics, dashes, semicolons and dots")
      @migrations.any? {|m| m[2] == name} && fail('"%s" migration already exists' % name)
      
      context = {name: name, step: @migrations.size + 1}
      model   = @setups[:create_table] || @setups[:update_table]
      [:create_table, :update_table].each do |o|
        context[o] = (m = constant_defined?(@setups[o])) ? model_to_table(m) : nil
      end
      [:create_columns, :update_columns].each do |o|
        context[o] = (@setups[o]||[]).map {|(n,t)| [n, opted_column_type(t)]}
      end
      context[:rename_columns] = @setups[:rename_columns]||[]

      if table = context[:create_table]
        columns = context[:create_columns]
      elsif table = context[:update_table]
        columns = (_ = context[:create_columns]).any? ? _ : context[:update_columns]
      else
        fail('No model provided or provided one does not exists!
          Please use "enginery migration [create|update]_table:ModelName ..."')
      end

      track_file = dst_path(:migrations, :track, 'column_transitions.yml')
      track_data = File.file?(track_file) ? (YAML.load(File.read(track_file)) rescue {}) : {}
      track_data[table] ||= {}
      columns.each do |column|
        column << track_data[table][column.first]
        track_data[table][column.first] = column[1]
      end
      FileUtils.mkdir_p File.dirname(track_file)
      File.open(track_file, 'w') {|f| f << YAML.dump(track_data)}

      engine = Tenjin::Engine.new(path: [src_path.migrations], cache: false)
      source_code = engine.render("#{guess_orm}.erb", context)
      o
      o '--- %s model - generating "%s" migration ---' % [model, name]
      o
      o '  Serial Number: %s' % context[:step]
      o
      time = Time.now.strftime(TIME_FORMAT)
      file = dst_path(:migrations, [context[:step], time, name, 'rb']*'.')
      write_file file, source_code
      output_source_code source_code.split("\n")
    end

    # convert given range or a single migration into files to be run
    # ex: 1-5 will run migrations from one to 5 inclusive
    #     1 2 4 will run 1st, 2nd, and 4th migrations
    #     2 will run only 2nd migration
    def serials_to_files vector, *serials
      vector = validate_vector(vector)
      serials.map do |serial|
        if serial =~ /\-/
          a, z = serial.split('-')
          (a..z).to_a
        else
          serial
        end
      end.flatten.map do |e|
        @migrations.find {|m| m.first == e.to_i} ||
          fail('Wrong range provided. "%s" is not a recognized migration step' % e)
      end.sort do |a,b|
        vector == :up ? a.first <=> b.first : b.first <=> a.first
      end.map {|m| File.basename m.last}
    end

    # - validate migration file name
    # - apply migration in given direction if:
    #   * migration was not previously performed in given direction
    #   * :force option given
    # - create a file with same name in track/ dir
    #   so on consequent requests we may know when migration was last performed
    def run vector, file, force_run = nil
      vector = validate_vector(vector)
      
      (migration = @migrations.find {|m| File.basename(m.last) == file}) ||
        fail('"%s" is not a valid migration file' % file)
      
      track = dst_path(:migrations, :track, file)
      if File.exists?(track) && !force_run
        track_data = File.read(track)
        if track_data =~ %r[\A#{vector}]i
          o
          o '  This migration was already performed %s' % track_data
          o '  Use :force option to run it anyway - enginery m:%s:force ...' % vector 
          o
          fail
        end
      end
      if apply!(migration, vector)
        FileUtils.mkdir_p File.dirname(track)
        File.open(track, 'w') {|f| f << [vector.to_s.upcase, DateTime.now.rfc2822]*' on '}
      end
    end

    # list available migrations with date of last run, if any
    def list
      o indent('--'), '-=---'
      @migrations.each do |(step,time,name,file)|
        file  = File.basename(file)
        track = dst_path(:migrations, :track, file)
        last_perform = File.exists?(track) ? File.read(track) : 'none'
        o indent(step), ' : ', name
        o indent('created at'), ' : ', DateTime.strptime(time, TIME_FORMAT).rfc2822
        o indent('last performed'), ' : ', last_perform
        o indent('--'), '-=---'
      end
    end

    private

    # load migration file and call corresponding methods that will run migration up/down
    def apply! migration, vector, orm = guess_orm
      o
      o '*** Running %s step #%s ***' % [vector, migration.first]
      o '     Label: %s' % migration[2]
      o '       ORM: %s' % orm
      begin
        
        require migration.last

        case orm
        when :DataMapper
          ::EngineryMigratorInstance.send 'perform_%s' % vector
        when :ActiveRecord
          ::EngineryMigratorInstance.new.send vector
        when :Sequel
          ::EngineryMigratorInstance.apply DB, vector
        end
        o '    status: OK'
        true
      rescue => e
        o '    status: failed'
        o '     error: %s' % e.message
        e.backtrace.each{|l| o l}
        fail
      end
    end

    # get the actual db table of a given model
    def model_to_table model
      case guess_orm
      when :DataMapper
        model.repository.adapter.resource_naming_convention.call(model)
      when :ActiveRecord, :Sequel
        model.table_name
      end
    rescue
      nil
    end

    def default_column_type orm = guess_orm
      case orm
      when :ActiveRecord
        'string'
      when :DataMapper, :Sequel
        'String'
      end
    end

    # convert given string into column type suitable for migration file
    def opted_column_type type, orm = nil
      orm  ||= guess_orm
      type ||= default_column_type(orm)
      case orm
      when :DataMapper
        constant_name = 'DataMapper::Property::%s' % capitalize(type)
        constant_defined?(constant_name) || ("'%s'" % type)
      when :Sequel
        type.to_s =~ /text/i ? "String, text: true" : capitalize(type)
      else
        type
      end
    end

    # someString.capitalize will return Somestring.
    # we need SomeString instead, which is returned by this method
    def capitalize smth
      smth.to_s.match(/(\w)(.*)/) {|m| m[1].upcase << m[2]}
    end

    def guess_orm
      @setups[:orm] || Cfg[:orm] || fail('No project-wide ORM detected.
        Please update config/config.yml by adding "orm: [:DataMapper|:ActiveRecord|:Sequel]"
        or provide it via orm option - orm:[ar|dm|sq]')
    end

    def validate_vector vector
      invalid_vector!(vector) unless vector.is_a?(String)
      (vector =~ /\Au/i) && (vector = :up)
      (vector =~ /\Ad/i) && (vector = :down)
      invalid_vector!(vector) unless vector.is_a?(Symbol)
      vector
    end

    def invalid_vector! vector
      fail('%s is a unrecognized vector. Use either "up" or "down"' % vector.inspect)
    end
    
    def indent smth
      string = smth.to_s
      ident_size = 20 - string.size
      ident_size =  0 if ident_size < 0
      INDENT + ' '*ident_size + string
    end

  end
end
