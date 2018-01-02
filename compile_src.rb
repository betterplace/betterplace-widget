class CompileSrc
  attr_accessor :app

  def initialize(app)
    self.app = app
  end

  def call(env)
    compile!
    app.call(env)
  end

  private

  def compile!
    production? and return

    # Compile riot
    `riot --compact src/ compile/riot-tags.js`

    # Merge js files
    js_files = %w[
      compile/es6-promise.js
      compile/fetch.js
      compile/riot.js
      compile/riot-tags.js
    ]
    js_content = js_files.map { |file| File.read(file) }.join("\n")
    File.write('public/js/widget.min.js', js_content)
  end

  def production?
    ENV['RACK_ENV'] == 'production'
  end
end
