# Common developer tasks

install:
	bundle install

serve:
	bundle exec jekyll serve --livereload

build:
	bundle exec jekyll build

test:
	bundle exec rake test

bench-build:
	# Requires hyperfine installed locally
	hyperfine 'bundle exec jekyll build --trace' --warmup 1