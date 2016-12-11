class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    doggy = Dog.new(hash)
    doggy.save
    doggy.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    doggy
  end

  def self.find_by_id(id_num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    pup_info = DB[:conn].execute(sql, id_num)[0]

    pup = Dog.new_from_db(pup_info)
    pup
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    doggy_array = DB[:conn].execute(sql, name, breed)

    if doggy_array.empty?
      doggy = Dog.create(name: name, breed: breed)
    else
      dog = doggy_array[0]
      doggy = Dog.new_from_db(dog)
    end
    doggy
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    doggy = DB[:conn].execute(sql, name)
    dog = Dog.new_from_db(doggy[0])
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
      breed = ?
      WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
    dog
  end
end
