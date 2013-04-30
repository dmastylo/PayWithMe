VANITY_ENVIRONMENTS = %w{development production}

def vanity_tables_exist?
  ActiveRecord::Base.connection.table_exists?('vanity_experiments')
end

def vanity_environment?
  VANITY_ENVIRONMENTS.include?(Rails.env)
end

Vanity.playground.collecting = vanity_tables_exist? && vanity_environment?