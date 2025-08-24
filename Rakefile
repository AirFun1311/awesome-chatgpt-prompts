# Build the Jekyll site
require "rake"

desc "Build site"
task :build do
  sh "bundle exec jekyll build"
end

desc "Serve site locally with livereload"
task :serve do
  sh "bundle exec jekyll serve --livereload"
end

desc "Test built site with html-proofer"
task :test => :build do
  # Disable external link checks to avoid CI rate limits; focus on internal link health
  sh "bundle exec htmlproofer --disable-external --assume-extension .html --allow-hash-href ./_site"
end