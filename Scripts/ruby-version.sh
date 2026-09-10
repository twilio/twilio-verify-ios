#!/bin/bash
chmod +x "$0"
echo "Using Ruby ${RUBY_VERSION}"
rbenv install ${RUBY_VERSION} || true
rbenv global ${RUBY_VERSION}
ruby -v
gem install bundler
